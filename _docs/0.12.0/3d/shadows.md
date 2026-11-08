---
title: Shadows
permalink: /docs/0.12.0/3d/shadows
---

A `DirectionalShadowMap` lets the directional light of a [PBREnvironment](/docs/0.12.0/3d/basics) cast shadows. The shadow casters are rendered into the shadow map first and then the scene is rendered as usual.

## Shadow Map

Creates a [DirectionalShadowMap](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/shadow/DirectionalShadowMap.kt) and passes it to the environment. More cascades keep shadows sharp over a longer `shadowDistance`.

```kotlin
val shadowMap = DirectionalShadowMap(device, cascadeCount = 3)
shadowMap.shadowDistance = 40f

val lightDirection = MutableVec3f(0.5f, 0.8f, 0.3f).norm()
val environment =
    PBREnvironment(device, shadowMap = shadowMap).apply {
        setDirectionalLight(DirectionalLight(direction = lightDirection, intensity = 2.5f))
    }
```

## Shadow Batch

A second `ModelBatch` renders the shadow casters using a [ShadowMaterialPipelineProvider](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/shadow/ShadowMaterialPipelineProvider.kt).

```kotlin
val shadowBatch =
    ModelBatch(device).apply {
        defaultPipelineProvider = ShadowMaterialPipelineProvider()
        depthFormat = shadowMap.format
    }
```

## Rendering

Update and render the shadow map before the main render pass.

```kotlin
onUpdate { dt ->
    camera.update()
    shadowMap.update(lightDirection, camera)

    val commandEncoder = device.createCommandEncoder()
    shadowMap.render(commandEncoder, shadowBatch, models, dt)

    val renderPass = ... // main render pass
    models.forEach { modelBatch.render(it, camera, environment) }
    modelBatch.flush(renderPass, camera, dt)
    renderPass.end()
}

onRelease {
    shadowBatch.release()
    shadowMap.release()
}
```

## Shadow Casters

Only materials with `castShadows` enabled are rendered into the shadow map. Materials with an `alphaCutoff` cast cut out shadows.

```kotlin
val floorMaterial = PBRMaterial(device, baseColorTexture = checkered, castShadows = false)

val fox =
    resourcesVfs["models/Fox.glb"].readGltfModel(
        config = GltfLoaderPbrConfig(GltfModelConfig(castShadows = true, skinned = true))
    )
```
