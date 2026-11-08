---
title: MSAA
permalink: /docs/0.12.0/3d/msaa
---

Multisample anti-aliasing (MSAA) smooths out jagged edges. The scene is rendered into multisampled textures that are then resolved into the frame.

## Sample Count

Sets the `ModelBatch` sample count. It must be either `1` or `4`.

```kotlin
val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = preferredFormat
        depthFormat = TextureFormat.DEPTH24_PLUS_STENCIL8
        sampleCount = 4
    }
```

## Multisampled Textures

The color and depth textures must use the same sample count as the `ModelBatch`.

```kotlin
fun createAttachment(width: Int, height: Int, format: TextureFormat) =
    device.createTexture(
        TextureDescriptor(
            Extent3D(width, height, 1),
            1,
            4, // sample count
            TextureDimension.D2,
            format,
            TextureUsage.RENDER_ATTACHMENT,
        )
    )

val msaaTexture = createAttachment(graphics.width, graphics.height, preferredFormat)
val msaaView = msaaTexture.createView()
val depthTexture =
    createAttachment(graphics.width, graphics.height, TextureFormat.DEPTH24_PLUS_STENCIL8)
val depthView = depthTexture.createView()
```

## Resolving

Render into the multisampled view and resolve it into the frame with `resolveTarget`.

```kotlin
val renderPass =
    commandEncoder.beginRenderPass(
        RenderPassDescriptor(
            listOf(
                RenderPassColorAttachmentDescriptor(
                    view = msaaView,
                    loadOp = LoadOp.CLEAR,
                    storeOp = StoreOp.DISCARD,
                    clearColor = clearColor,
                    resolveTarget = frame, // our surface frame
                )
            ),
            depthStencilAttachment =
                RenderPassDepthStencilAttachmentDescriptor(
                    view = depthView,
                    depthClearValue = 1f,
                    depthLoadOp = LoadOp.CLEAR,
                    depthStoreOp = StoreOp.STORE,
                    stencilClearValue = 0,
                    stencilLoadOp = LoadOp.CLEAR,
                    stencilStoreOp = StoreOp.STORE,
                ),
        )
    )
modelBatch.render(model, camera, environment)
modelBatch.flush(renderPass, camera, dt)
renderPass.end()
```
