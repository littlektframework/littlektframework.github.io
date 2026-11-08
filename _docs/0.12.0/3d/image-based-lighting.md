---
title: Image Based Lighting
permalink: /docs/0.12.0/3d/image-based-lighting
---

Image based lighting (IBL) lights PBR materials with an HDR image of the surroundings. A `Skybox` can then draw that same image behind the scene.

## Environment Map

Loads an equirectangular `.hdr` image and bakes it into an [EnvironmentMap](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/ibl/EnvironmentMap.kt).

```kotlin
val environmentMap =
    EnvironmentMap(device, resourcesVfs["hdri/sky.hdr"].readHdrImage())
```

## Environment

Passes the environment map to a [PBREnvironment](/docs/0.12.0/3d/basics). The `intensity` scales the image based lighting.

```kotlin
val environment = PBREnvironment(device, environmentMap = environmentMap)
environmentMap.intensity = 1.5f
```

## Skybox

Creates a [Skybox](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/ibl/Skybox.kt) with the same color and depth formats as the `ModelBatch`. A higher `lod` blurs the sky.

```kotlin
val skybox = Skybox(device, environmentMap, hdrFormat, depthFormat)
skybox.lod = 2f
skybox.intensity = 0.8f
```

## Rendering

Render the skybox in the same render pass, after the scene.

```kotlin
onUpdate { dt ->
    val renderPass = ... // main render pass
    models.forEach { modelBatch.render(it, camera, environment) }
    modelBatch.flush(renderPass, camera, dt)
    skybox.render(renderPass, camera)
    renderPass.end()
}

onRelease {
    skybox.release()
    environmentMap.release()
}
```

## HDR

The environment is brighter than `1.0`, so it pairs best with [HDR and Tonemapping](/docs/0.12.0/3d/hdr-and-tonemapping).

```kotlin
val hdrFormat = TextureFormat.RGBA16_FLOAT
val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = hdrFormat
    }
val skybox = Skybox(device, environmentMap, hdrFormat)
val tonemapper = Tonemapper(device, graphics.preferredFormat)
```
