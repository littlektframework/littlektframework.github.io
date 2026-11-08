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

The color and depth [render targets](/docs/0.12.0/2d/render-targets) must use the same sample count as the `ModelBatch`. They resize with the window.

```kotlin
val msaaTarget = renderTarget(preferredFormat, sampleCount = 4)
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8, sampleCount = 4)
```

## Resolving

Render into the multisampled view and resolve it into the frame with `resolveTarget`.

```kotlin
renderFrame { frame, commandEncoder ->
    val renderPass =
        commandEncoder.beginRenderPass(
            RenderPassDescriptor(
                colorAttachment(msaaTarget.view, clearColor, resolveTarget = frame), // our surface frame
                depthStencilAttachment = depthTarget.depthAttachment(),
            )
        )
    modelBatch.render(model, camera, environment)
    modelBatch.flush(renderPass, camera, dt)
    renderPass.end()
}
```
