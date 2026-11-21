---
title: 3D Basics
permalink: /docs/0.13.0/3d/basics
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
fox.play("Walk")

onUpdate { dt ->
    fox.update(dt)
}
```

A loaded model owns its meshes, materials, skins, and textures. Release it when done. Copies of a model share these, so only release the original.

```kotlin
onRelease {
    duck.release()
    fox.release()
}
```

Releasing a model also frees anything the `ModelBatch` cached for it. Custom `Material` subclasses that override `release()` must call `super.release()`.

## Animations

A skinned model's clips are in `Model.animations` and advance in `Model.update(dt)`, or `updateAnimations(dt)` on its own. `play` crossfades every other clip out over `fade`, which defaults to `Model.defaultFade` (200ms). A clip that isn't already playing, or has finished, starts from its beginning. Pass `restart = true` to always start over, or `Duration.ZERO` to switch at once.

```kotlin
fox.play("Walk")

val run = fox.findAnimation("Run")!!
fox.play(run, fade = 300.milliseconds)

fox.stop()
```

`stop` fades every clip out, blending back to the rest pose. `currentAnimation` is the clip last played, or `null` once stopped.

### Play Once

With `loop = false` a clip holds its last pose and sets `isFinished`. Use `onFinished` to go back to another clip.

```kotlin
val survey = fox.play("Survey", loop = false)
survey.onFinished = { fox.play("Walk") }
```

### Events

Events fire in `onEvent` when playback crosses their time in seconds, including when looping or playing in reverse with a negative `speed`. Remove them with `removeEvent` or `clearEvents`.

```kotlin
run.addEvent(0.2f, "step")
run.onEvent = { event -> if (event.name == "step") playFootstep() }
```

Clips fading out fire neither events nor `onFinished`.

### Speed and Weights

Each `Animation` has a `speed`, `progress`, `duration`, and `weight`. The weights of every playing clip are normalized, and a total below 1 blends with the rest pose.

```kotlin
run.speed = 1.5f
```

`enableAnimation(index)` still switches to a clip at full weight at once, and `setAnimationWeight(index, weight)` sets a weight by hand. Both cancel any fade.

See the [SkinnedAnimationExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/SkinnedAnimationExample.kt) (`-skinnedAnimation`) for crossfading, a play once clip, and footstep events.

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
