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

A loaded model owns its meshes, materials, skins, and textures. Release it when done. Copies of a model share these, so only release the original.

```kotlin
onRelease {
    duck.release()
    fox.release()
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
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8) // resizes with the window

val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(UnlitMaterialPipelineProvider())
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = graphics.preferredFormat
        depthFormat = depthTarget.format
    }
```

## Rendering

Add each model with `render` and then draw them all with `flush`. Passing the camera to `render` culls anything outside of its view.

```kotlin
val camera = PerspectiveCamera(graphics.width, graphics.height)
camera.translate(0f, 1f, 5f)

val clearColor = graphics.surfaceColor(Color.DARK_GRAY)

onUpdate { dt ->
    renderFrame { frame, commandEncoder ->
        val renderPass =
            commandEncoder.beginRenderPass(
                RenderPassDescriptor(
                    colorAttachment(frame, clearColor),
                    depthStencilAttachment = depthTarget.depthAttachment(),
                )
            )
        camera.update()
        modelBatch.render(duck, camera, environment)
        modelBatch.render(fox, camera, environment)
        modelBatch.flush(renderPass, camera, dt)
        renderPass.end()
    }
}

onRelease {
    modelBatch.release()
    environment.release()
}
```
