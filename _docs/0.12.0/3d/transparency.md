---
title: Transparency
permalink: /docs/0.12.0/3d/transparency
---

A `ModelBatch` sorts transparent instances back to front automatically. There is nothing extra to do when rendering.

## Transparent Materials

Set `transparent = true` on a material. Disabling `depthWrite` lets the surfaces behind it show through.

```kotlin
val glass =
    PBRMaterial(
        device,
        baseColorTexture = Textures.textureWhite,
        baseColorFactor = Color(1f, 1f, 1f, 0.35f),
        transparent = true,
        doubleSided = true,
        depthWrite = false,
    )
```

## glTF Models

glTF materials using the `BLEND` alpha mode are transparent automatically.

```kotlin
val model = resourcesVfs["models/glass.glb"].readGltfModel()
modelBatch.render(model, camera, environment)
```

## Custom Pipelines

A custom `MaterialPipelineProvider` opts in with `transparent` on the `MaterialPipeline`. It defaults to `true` when the `renderOrder` is `RenderOrder.TRANSPARENT`.

```kotlin
return MaterialPipeline(
    shader = shader,
    environment = environment,
    renderOrder = RenderOrder.TRANSPARENT,
    layout = layout,
    renderPipeline = renderPipeline,
    transparent = true,
)
```
