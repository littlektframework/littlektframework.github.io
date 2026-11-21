---
title: Decals & Depth
permalink: /docs/0.13.0/3d/decals
---

Decals and soft particles read the depth of the opaque geometry. Render the opaque pass first, then draw them in a second pass that tests against the same depth while sampling it.

## Readable Depth

A depth texture can't be written and sampled in the same pass. `readOnlyDepthAttachment()` attaches it without clearing or writing, and `depthView` is a depth only view to sample it. `depthView` follows `resize`.

The depth texture needs `TextureUsage.TEXTURE`. `renderTarget` has it by default.

```kotlin
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8)
```

Each frame, end the opaque pass, then begin a second pass that loads the color (`colorAttachment` without a clear color) and attaches the depth read only.

```kotlin
renderFrame { frame, commandEncoder ->
    particles.simulate(commandEncoder, emitters)

    val opaque =
        commandEncoder.beginRenderPass(
            RenderPassDescriptor(
                colorAttachment(frame, clearColor),
                depthStencilAttachment = depthTarget.depthAttachment(),
            )
        )
    modelBatch.render(scene, environment)
    modelBatch.flush(opaque, camera, dt)
    opaque.end()
    opaque.release()

    val overlay =
        commandEncoder.beginRenderPass(
            RenderPassDescriptor(
                colorAttachment(frame), // load
                depthStencilAttachment = depthTarget.readOnlyDepthAttachment(),
            )
        )
    decals.render(overlay, camera, depthTarget, decalList)
    particles.render(overlay, camera, emitters, depthTarget)
    overlay.end()
    overlay.release()
}
```

Other transparent draws, such as [billboards](/docs/0.13.0/3d/billboards), can go in the second pass too. Set their `depthFormat` to the depth target's.

### MSAA

Use a multisampled depth texture. Depth is read from its first sample, and the decal pipelines match its sample count automatically. Set `sampleCount = 4` on the `ParticleRenderer` and other batches as usual.

```kotlin
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8, sampleCount = 4)
val msaaColor = renderTarget(preferredFormat, sampleCount = 4)
```

The opaque pass must store the MSAA color so the second pass can load it and resolve to the frame.

```kotlin
// opaque
colorAttachment(msaaColor.view, clearColor, frame, StoreOp.STORE)

// overlay
colorAttachment(msaaColor.view, resolveTarget = frame)
```

## Decals

A [Decal](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/Decal.kt) projects a texture onto the geometry inside its box, such as a targeting circle, a scorch mark, or a puddle. It is a `Node3D`, so it can be moved, rotated, and added as a child.

The box is `1` unit on each axis around the node, sized by its scale. The texture is projected down the node's local y axis, so the y scale is how far it reaches up and down.

```kotlin
val scorch =
    Decal(scorchTexture.slice(), Color(0.05f, 0.04f, 0.03f, 0.85f)).apply {
        position(2f, 0f, 3f)
        scaling(3f, 1f, 3f)
        rotate(y = 45.degrees)
    }
```

`slice` and `color` can change at any time. Update decals like other nodes before drawing.

### Fading

- `angleFade` fades surfaces turned further than this from facing the projection, so decals don't smear down walls. `70.degrees` by default.
- `edgeFade` fades this much of the box's height at its top and bottom, `0` to `0.5`. `0.1` by default.

```kotlin
val ring =
    Decal(ringTexture.slice(), Color(1f, 0.4f, 0.2f, 0.9f)).apply {
        scaling(2.5f, 3f, 2.5f) // tall enough to cover ramps and steps
        angleFade = 50.degrees
    }
unit.addChild(ring)
```

### Renderer

A [DecalRenderer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/DecalRenderer.kt) draws decals in the read only depth pass. Set the formats to match it.

```kotlin
val decals =
    DecalRenderer(device).apply {
        colorFormat = graphics.preferredFormat
        depthFormat = depthTarget.format
    }

decals.render(overlay, camera, depthTarget, decalList) // or a single decal
```

Decals with the same texture next to each other in the list are drawn together, so group them by texture. `blendState` sets how they mix with the surface, `BlendState.NonPreMultiplied` by default. Rendering with more than `maxViewsPerFrame` cameras (`8` by default) in one frame needs a higher value.

Decals draw on every surface in the box, including moving models. Release the renderer when done. Decals don't own their textures.

## Soft Particles

Particles fade out where they meet geometry instead of cutting a hard line. Set `softness` on the effect, in world units, and pass the depth texture as the last argument of `render` in the read only depth pass.

```kotlin
val smoke = ParticleEffect(rate = 40f, size = 1f..1.6f, softness = 0.6f)

particles.render(overlay, camera, emitters, depthTarget)
```

Effects with `softness = 0f`, or rendered without a depth texture, draw hard. See [GPU Particles](/docs/0.13.0/3d/gpu-particles).

See the [DecalsExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/DecalsExample.kt) for a targeting ring over ramps and steps, scorch marks, a puddle, and soft smoke.
