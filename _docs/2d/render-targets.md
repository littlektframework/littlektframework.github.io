---
title: Render Targets
permalink: /docs/2d/render-targets
---

WebGPU makes render targets/framebuffer objects easy. There is no need for an API to be built on top as a RenderPassEncoder is essentially a render target. Instead of rendering the surface frame, as we usually do, we can create an `EmptyTexture` of a specified size and use it as the output in a render pass.


## EmptyTexture

Creates a new `Texture` of size 256, 256.

```kotlin
val preferredFormat = graphics.preferredFormat
val target = EmptyTexture(device, preferredFormat, 256, 256)
```

## Rendering to a Texture

Render to a texture.

```kotlin
val commandEncoder = device.createCommandEncoder("command encoder")
val renderTargetRenderPass =
    commandEncoder.beginRenderPass(
        RenderPassDescriptor(
            listOf(
                RenderPassColorAttachmentDescriptor(
                    view = target.view, // our texture specified here!
                    loadOp = LoadOp.CLEAR,
                    storeOp = StoreOp.STORE,
                    clearColor =
                        if (preferredFormat.srgb) Color.YELLOW.toLinear()
                        else Color.YELLOW
                )
            ),
            label = "Surface render pass"
        )
    )

batch.begin()
batch.draw(mySprite, 0f, 0f) // we are drawing to the render target
batch.flush(renderTargetRenderPass)
renderTargetRenderPass.end()

val surfaceRenderPass =
    commandEncoder.beginRenderPass(
        RenderPassDescriptor(
            listOf(
                RenderPassColorAttachmentDescriptor(
                    view = frame,
                    loadOp = LoadOp.CLEAR,
                    storeOp = StoreOp.STORE,
                    clearColor =
                        if (preferredFormat.srgb) Color.DARK_GRAY.toLinear()
                        else Color.DARK_GRAY
                )
            ),
            label = "Surface render pass"
        )
    )
// now we draw the render target ouput to the surface frame
batch.draw(
    target,
    0f,
    0f,
    originX = target.width * 0.5f,
    originY = target.height * 0.5f,
)
batch.flush(surfaceRenderPass)
batch.end()
surfaceRenderPass.end()
```
