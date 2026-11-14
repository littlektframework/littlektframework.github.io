---
title: Skinned Instancing
permalink: /docs/0.12.0/3d/skinned-instancing
---

Draws large crowds of animated, skinned models. A
[BakedAnimations](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/skin/BakedAnimations.kt)
bakes every animation of a skinned `Model` into joint matrices on the GPU once. Each
[BakedAnimationInstance](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/skin/BakedAnimationInstance.kt)
is a `Node3D` with its own clip, time, and speed.

## Baking

```kotlin
val fox =
    resourcesVfs["models/Fox.glb"].readGltfModel(
        GltfLoaderUnlitConfig(GltfModelConfig(skinned = true))
    )
val baked = BakedAnimations(device, fox, fps = 30f)

baked.clips // every baked clip
baked.clip("Run") // a clip by name, or null
```

Release it when done. The source model must stay loaded since its meshes and materials are shared.

```kotlin
onRelease {
    baked.release()
    fox.release()
}
```

## Instances

Animations advance when `update(dt)` is called, e.g. on a parent node.

```kotlin
val horde = Node3D()
repeat(1000) {
    horde.addChild(
        baked.createInstance().apply {
            play("Run") // or play(clip, loop = true, restart = true)
            speed = 1.2f
            tint = Color.RED
            position(it % 40 * 2.5f, 0f, it / 40 * 2.5f)
        }
    )
}

onUpdate { dt ->
    horde.update(dt)
    // ...
    modelBatch.render(horde, camera, environment)
}
```

Use `stop()`, `time`, `loop`, and `isFinished` to control playback. Call `remove()` to stop drawing an instance for good.

## Crossfading

Pass a `fade` to `play` to blend from the current clip instead of snapping. The old clip keeps playing, scaled by `speed`, while its weight drops linearly to zero.

```kotlin
enemy.play("Attack", loop = false, fade = 0.2.seconds)

enemy.defaultFade = 0.3.seconds // used when no fade is given, zero by default
enemy.play("Run")
```

`fadingClip` is the clip fading out and `isFading` is true until it finishes. Starting a new fade mid-fade fades from the current clip only.

## Performance

All instances of one `BakedAnimations` are drawn in one instanced draw call per mesh primitive, are frustum culled, and have their frames and crossfades interpolated on the GPU. 3000 animated foxes run at the 120 FPS vsync cap on the JVM.

Blending is limited to crossfading two clips, and there are no procedural bones. Use a regular `Model` with a live skin for hero characters.

## Skinned Model Copies

Copies of a skinned `Model` draw wherever they are placed. To pose an animation at a time without advancing it, use `Animation.sample(time)`.

```kotlin
fox.animations[0].sample(0.5f)
```
