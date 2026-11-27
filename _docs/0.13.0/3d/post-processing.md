---
title: Post Processing
permalink: /docs/0.13.0/3d/post-processing
---

A `PostProcessor` runs a chain of fullscreen effects over a rendered image, such as an [HDR texture](/docs/0.13.0/3d/hdr-and-tonemapping), and draws the result into your own render pass.

## Post Processor

Creates a [PostProcessor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/postprocess/PostProcessor.kt). Its `format` is used for the textures between effects and defaults to `RGBA16_FLOAT` to keep HDR colors. The `effects` run in order and disabled effects are skipped.

```kotlin
val tonemapper = Tonemapper(device, graphics.preferredFormat)
val fxaa = FxaaEffect(device)
val vignette = VignetteEffect(device).apply { intensity = 0.5f }

val post = PostProcessor(device).apply { effects += listOf(tonemapper, fxaa, vignette) }
```

Effects work in linear color. Results are encoded to sRGB automatically when the final target isn't sRGB or float. Put the `Tonemapper` first, which sets its own format from the chain, followed by effects that expect a `[0, 1]` range, such as `FxaaEffect`.

## Rendering

Each frame takes two calls. `process` runs every enabled effect but the last into two internal ping-pong textures, and `render` draws the last effect into your pass. With no enabled effects, the source is copied. [Bloom](/docs/0.13.0/3d/bloom) stays a step before `process`.

```kotlin
renderFrame { frame, commandEncoder ->
    val scenePass = ... // HDR render pass
    modelBatch.render(model, camera, environment)
    modelBatch.flush(scenePass, camera, dt)
    scenePass.end()

    bloom.render(commandEncoder, hdrTarget.view, hdrTarget.width, hdrTarget.height)
    post.process(commandEncoder, hdrTarget.view, hdrTarget.width, hdrTarget.height)

    val surfacePass = commandEncoder.beginRenderPass(RenderPassDescriptor(colorAttachment(frame)))
    post.render(surfacePass, graphics.preferredFormat)
    surfacePass.end()
}
```

UI can be drawn after `post.render` in the same pass.

The effects aren't released with the processor.

```kotlin
onRelease {
    post.release()
    tonemapper.release()
    fxaa.release()
    vignette.release()
}
```

## Built-in Effects

Every effect has an `enabled` toggle.

```kotlin
val fxaa = FxaaEffect(device)
val vignette =
    VignetteEffect(device).apply {
        intensity = 0.4f
        radius = 1f
        softness = 0.6f
    }
val colorAdjust =
    ColorAdjustEffect(device).apply {
        brightness = 1f
        contrast = 1.2f
        saturation = 0.4f
    }
val chromatic = ChromaticAberrationEffect(device).apply { strength = 0.01f }

colorAdjust.enabled = false
```

## Distortion

A [DistortionEffect](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/postprocess/DistortionEffect.kt) bends the image where distortion was drawn, such as heat haze and shockwaves. Put it before the `Tonemapper`.

```kotlin
val distortion =
    DistortionEffect(device).apply {
        strength = 0.04f // push as a fraction of the screen height
        chromatic = 0.15f // red and blue split
    }
val post = PostProcessor(device).apply { effects += listOf(distortion, tonemapper) }
```

Each frame, draw [DISTORT particles](/docs/0.13.0/3d/gpu-particles#distortion) into the pass from `beginPass` after the scene pass, and end it before `process`. `ringTexture` and `hazeTexture` are ready made distortion maps.

```kotlin
val warpPass = distortion.beginPass(commandEncoder, hdrTarget.width, hdrTarget.height)
particles.render(warpPass, camera, warps, depthTarget)
warpPass.end()

post.process(commandEncoder, hdrTarget.view, hdrTarget.width, hdrTarget.height)
```

Releasing the effect releases its target and textures.

## Custom Effects

A [ShaderPostEffect](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/postprocess/ShaderPostEffect.kt) takes WGSL that defines `fn effect(uv: vec2f) -> vec4f` and returns the linear color at `uv`. It can use:

- `source` and `source_sampler`, the image so far
- `post.resolution` and `post.texel`, the size of `source` and of one pixel in uv
- `post.params[i]`, `paramCount` floats packed into `vec4f`s, set with `setParam` and read with `getParam`

```kotlin
val pixelate =
    ShaderPostEffect(
            device,
            """
            fn effect(uv: vec2f) -> vec4f {
                let size = post.params[0].x * post.texel;
                return textureSample(source, source_sampler, (floor(uv / size) + 0.5) * size);
            }
            """,
            paramCount = 1,
            label = "pixelate effect",
        )
        .apply { setParam(0, 6f) }

post.effects += pixelate
```

Subclass it to expose typed properties.

```kotlin
class InvertEffect(device: Device) :
    ShaderPostEffect(
        device,
        """
        fn effect(uv: vec2f) -> vec4f {
            let color = textureSample(source, source_sampler, uv);
            return vec4f(mix(color.rgb, 1.0 - color.rgb, post.params[0].x), color.a);
        }
        """,
        paramCount = 1,
    ) {
    var amount: Float
        get() = getParam(0)
        set(value) = setParam(0, value)
}
```

### Extra Textures

`textureCount` adds textures `post_texture_0` to `post_texture_<textureCount - 1>`, sampled with `source_sampler`. Set each with `setTexture` before the effect renders.

```kotlin
val tint =
    ShaderPostEffect(
            device,
            """
            fn effect(uv: vec2f) -> vec4f {
                let color = textureSample(source, source_sampler, uv);
                return color * textureSample(post_texture_0, source_sampler, uv);
            }
            """,
            textureCount = 1,
        )
        .apply { setTexture(0, tintTexture.view) }
```

### Depth Textures

`depthTextureCount` adds depth textures `post_depth_0` to `post_depth_<depthTextureCount - 1>`, read with `post_load_depth_<i>(uv)`. `post_linear_depth(depth)` turns a depth into the distance from the camera set with `setCamera` or `setDepthRange`. Set `depthSampleCount` for a multisampled depth texture.

```kotlin
val fog =
    ShaderPostEffect(
            device,
            """
            fn effect(uv: vec2f) -> vec4f {
                let color = textureSample(source, source_sampler, uv);
                let distance = post_linear_depth(post_load_depth_0(uv));
                let fog = clamp(1.0 - exp(-distance * post.params[0].x), 0.0, 1.0);
                return vec4f(mix(color.rgb, vec3f(0.01), fog), color.a);
            }
            """,
            paramCount = 1,
            depthTextureCount = 1,
        )
        .apply { setParam(0, 0.12f) }

// each frame, before process
fog.setDepthTexture(0, depthTarget.depthView)
fog.setCamera(camera)
```

Implement [PostEffect](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/postprocess/PostEffect.kt) directly for anything else. Its `render` draws `source` over the whole pass in the given `format`.

## Example

See the [PostProcessingExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/PostProcessingExample.kt) (`-postProcessing`) for bloom, a tonemapper, FXAA, a vignette, color adjustments, chromatic aberration, and a custom pixelate effect, each toggled by a number key. See the [VfxParticlesExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/VfxParticlesExample.kt) (`-vfxParticles`) for distortion. See the [SpotLightsExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/SpotLightsExample.kt) (`-spotLights`) for depth fog.
