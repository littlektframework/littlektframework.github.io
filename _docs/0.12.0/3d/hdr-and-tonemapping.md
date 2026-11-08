---
title: HDR and Tonemapping
permalink: /docs/0.12.0/3d/hdr-and-tonemapping
---

Rendering into a float texture keeps colors brighter than `1.0`. A `Tonemapper` then maps that HDR texture down to the surface.

## HDR Texture

Creates a window sized `RGBA16_FLOAT` [render target](/docs/0.12.0/2d/render-targets) to render the scene into, plus a depth target. The `ModelBatch` color format must match it.

```kotlin
val hdrTarget =
    renderTarget(
        TextureFormat.RGBA16_FLOAT,
        usage = TextureUsage.RENDER_ATTACHMENT or TextureUsage.TEXTURE,
    )
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8)

val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = hdrTarget.format
        depthFormat = depthTarget.format
    }
```

## Tonemapper

Creates a [Tonemapper](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/Tonemapper.kt) for the surface format. The `mode` can be `NONE`, `REINHARD`, `ACES` (default), `AGX`, or `NEUTRAL`.

```kotlin
val tonemapper = Tonemapper(device, graphics.preferredFormat)
tonemapper.mode = TonemapMode.AGX
tonemapper.exposure = 1.5f
```

## Rendering

Render the scene into the HDR texture and then tonemap it onto the surface frame.

```kotlin
renderFrame { frame, commandEncoder ->
    val scenePass =
        commandEncoder.beginRenderPass(
            RenderPassDescriptor(
                colorAttachment(hdrTarget.view, Color.DARK_GRAY.toLinear()),
                depthStencilAttachment = depthTarget.depthAttachment(),
            )
        )
    modelBatch.render(model, camera, environment)
    modelBatch.flush(scenePass, camera, dt)
    scenePass.end()

    val surfacePass = commandEncoder.beginRenderPass(RenderPassDescriptor(colorAttachment(frame)))
    tonemapper.render(surfacePass, hdrTarget.view)
    surfacePass.end()
}
```
