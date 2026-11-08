---
title: Multiple Cameras and Passes
permalink: /docs/0.12.0/3d/multiple-cameras-and-passes
---

A `ModelBatch` can be flushed more than once per frame. Each `flush` draws everything rendered since the last flush with its own camera and render pass.

## A Second Camera

Creates a top down camera and a texture to render it into, such as a minimap.

```kotlin
val minimapCamera = PerspectiveCamera(256, 256)
minimapCamera.translate(0f, 30f, 0f)
minimapCamera.rotate((-90).degrees, Vec3f.X_AXIS)

val minimap = EmptyTexture(device, preferredFormat, 256, 256)
```

## Rendering

Render the models again for each camera before flushing to its render pass.

```kotlin
onUpdate { dt ->
    camera.update()
    minimapCamera.update()

    // pass 1: the minimap camera
    val minimapPass = ... // render pass using minimap.view
    models.forEach { modelBatch.render(it, minimapCamera, environment) }
    modelBatch.flush(minimapPass, minimapCamera, dt)
    minimapPass.end()

    // pass 2: the main camera
    val mainPass = ... // render pass using the surface frame
    models.forEach { modelBatch.render(it, camera, environment) }
    modelBatch.flush(mainPass, camera, dt)
    mainPass.end()
}
```

## Drawing the Minimap

The minimap can then be drawn on top of the frame with a [SpriteBatch](/docs/0.12.0/2d/spritebatch), just like a [render target](/docs/0.12.0/2d/render-targets).

```kotlin
val uiPass = ... // render pass using the surface frame with LoadOp.LOAD
spriteBatch.begin(uiCamera.viewProjection)
spriteBatch.draw(minimap, 10f, 10f)
spriteBatch.flush(uiPass)
spriteBatch.end()
uiPass.end()
```
