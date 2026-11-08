---
title: Render Targets
permalink: /docs/0.12.0/2d/render-targets
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
val targetClearColor = graphics.surfaceColor(Color.YELLOW)
val clearColor = graphics.surfaceColor(Color.DARK_GRAY)

renderFrame { frame, commandEncoder ->
    val renderTargetRenderPass =
        commandEncoder.beginRenderPass(
            RenderPassDescriptor(
                colorAttachment(target.view, targetClearColor), // our texture specified here!
                label = "Render target render pass"
            )
        )

    batch.begin()
    batch.draw(mySprite, 0f, 0f) // we are drawing to the render target
    batch.flush(renderTargetRenderPass)
    renderTargetRenderPass.end()

    val surfaceRenderPass =
        commandEncoder.beginRenderPass(
            RenderPassDescriptor(colorAttachment(frame, clearColor), label = "Surface render pass")
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
}
```

## Window Sized Targets

`renderTarget` creates an `EmptyTexture` the size of the window. It is resized and released automatically, which is handy for depth, multisampled, or HDR targets.

```kotlin
val colorTarget = renderTarget(graphics.preferredFormat)
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8)

val renderPass =
    commandEncoder.beginRenderPass(
        RenderPassDescriptor(
            colorAttachment(colorTarget.view, clearColor),
            depthStencilAttachment = depthTarget.depthAttachment(),
        )
    )
```
