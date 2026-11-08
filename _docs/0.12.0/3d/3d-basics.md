---
title: 3D Basics
permalink: /docs/0.12.0/3d/basics
---

A quick overview of loading a glTF model and drawing it with a `ModelBatch` and a `PBREnvironment`.

## Loading a glTF Model

Reads a `.glb` or `.gltf` file into a `Model`.

```kotlin
val duck = resourcesVfs["models/Duck.glb"].readGltfModel()
val fox =
    resourcesVfs["models/Fox.glb"].readGltfModel(
        config = GltfLoaderPbrConfig(GltfModelConfig(skinned = true))
    )
fox.scale(0.03f)
fox.enableAnimation(1)

onUpdate { dt ->
    fox.update(dt) // updates the animation
}
```

## Environment and Lights

A [PBREnvironment](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/PBREnvironment.kt) holds the lights used to shade PBR materials.

```kotlin
val environment =
    PBREnvironment(device).apply {
        setDirectionalLight(DirectionalLight(direction = Vec3f(0.3f, 0.5f, 0.8f), intensity = 2f))
        setAmbientLight(AmbientLight(color = Color(0.05f, 0.05f, 0.05f)))
        addPointLight(PointLight(Vec3f(0f, 1f, 0f), color = Color.RED, range = 2f))
    }
```

## ModelBatch

A [ModelBatch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/ModelBatch.kt) handles the pipelines for each material type. The formats must match the render pass attachments.

```kotlin
val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(UnlitMaterialPipelineProvider())
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = graphics.preferredFormat
        depthFormat = TextureFormat.DEPTH24_PLUS_STENCIL8
    }
```

## Rendering

Add each model with `render` and then draw them all with `flush`. Passing the camera to `render` culls anything outside of its view.

```kotlin
val camera = PerspectiveCamera(graphics.width, graphics.height)
camera.translate(0f, 1f, 5f)

onUpdate { dt ->
    val renderPass = ... // render pass with a color & depth attachment
    camera.update()
    modelBatch.render(duck, camera, environment)
    modelBatch.render(fox, camera, environment)
    modelBatch.flush(renderPass, camera, dt)
    renderPass.end()
}

onRelease {
    modelBatch.release()
    environment.release()
}
```
