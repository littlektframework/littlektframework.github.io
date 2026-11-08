---
title: HDR and Tonemapping
permalink: /docs/0.12.0/3d/hdr-and-tonemapping
---

Rendering into a float texture keeps colors brighter than `1.0`. A `Tonemapper` then maps that HDR texture down to the surface.

## HDR Texture

Creates an `RGBA16_FLOAT` texture to render the scene into. The `ModelBatch` color format must match it.

```kotlin
val hdrFormat = TextureFormat.RGBA16_FLOAT
val hdrTexture =
    device.createTexture(
        TextureDescriptor(
            Extent3D(graphics.width, graphics.height, 1),
            1,
            1,
            TextureDimension.D2,
            hdrFormat,
            TextureUsage.RENDER_ATTACHMENT or TextureUsage.TEXTURE,
        )
    )
val hdrView = hdrTexture.createView()

val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = hdrFormat
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
val scenePass =
    commandEncoder.beginRenderPass(
        RenderPassDescriptor(
            listOf(
                RenderPassColorAttachmentDescriptor(
                    view = hdrView,
                    loadOp = LoadOp.CLEAR,
                    storeOp = StoreOp.STORE,
                    clearColor = Color.DARK_GRAY.toLinear(),
                )
            ),
            depthStencilAttachment = ... // depth attachment
        )
    )
modelBatch.render(model, camera, environment)
modelBatch.flush(scenePass, camera, dt)
scenePass.end()

val surfacePass =
    commandEncoder.beginRenderPass(
        RenderPassDescriptor(
            listOf(
                RenderPassColorAttachmentDescriptor(
                    view = frame,
                    loadOp = LoadOp.CLEAR,
                    storeOp = StoreOp.STORE,
                )
            )
        )
    )
tonemapper.render(surfacePass, hdrView)
surfacePass.end()
```
