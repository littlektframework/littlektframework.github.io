---
title: Bloom
permalink: /docs/0.12.0/3d/bloom
---

Bloom adds a glow around the parts of an HDR texture brighter than a threshold. It is rendered after the scene and before the `Tonemapper`.

## Bloom

Creates a [Bloom](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/Bloom.kt) for the HDR texture format. More `mipLevels` give a wider glow.

```kotlin
val bloom = Bloom(device, TextureFormat.RGBA16_FLOAT, mipLevels = 6)
bloom.threshold = 1f
bloom.softKnee = 0.5f
bloom.intensity = 0.3f
bloom.radius = 1f
```

## Rendering

Render bloom on the HDR texture after the scene pass ends and then tonemap it. The HDR texture needs the `RENDER_ATTACHMENT` and `TEXTURE` usages and must not be multisampled.

```kotlin
onUpdate { dt ->
    renderFrame { frame, commandEncoder ->
        val scenePass = ... // HDR render pass
        modelBatch.render(model, camera, environment)
        modelBatch.flush(scenePass, camera, dt)
        scenePass.end()

        bloom.render(commandEncoder, hdrTarget.view, hdrTarget.width, hdrTarget.height)

        val surfacePass = ... // surface render pass
        tonemapper.render(surfacePass, hdrTarget.view)
        surfacePass.end()
    }
}

onRelease {
    bloom.release()
}
```

## Emissive Materials

An emissive `PBRMaterial` glows once its `emissiveFactor` goes over the `threshold`.

```kotlin
val material =
    PBRMaterial(
        device,
        baseColorTexture = Textures.textureWhite,
        emissiveFactor = Vec3f(4f, 1f, 0.5f),
    )
```

## HDR

Bloom needs colors brighter than `1.0`, so it requires [HDR and Tonemapping](/docs/0.12.0/3d/hdr-and-tonemapping).

```kotlin
val hdrFormat = TextureFormat.RGBA16_FLOAT
val modelBatch =
    ModelBatch(device).apply {
        addPipelineProvider(PBRMaterialPipelineProvider())
        colorFormat = hdrFormat
    }
val bloom = Bloom(device, hdrFormat)
val tonemapper = Tonemapper(device, graphics.preferredFormat)
```
