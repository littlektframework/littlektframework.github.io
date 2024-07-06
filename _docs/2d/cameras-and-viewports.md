---
title: Camera and Viewports
permalink: /docs/2d/cameras-and-viewports
---

The _Camera_ class and _Viewport_ class will seem very familiar if one has every used **libGDX**. They work the same in **LittleKt**. The camera can be use to manipluate the game world without having to manually handle any matrices. The viewport is used in tandem with the camera which supports dealing with different screen sizes / resolutions and aspect ratios.

## Using a Camera

The [Camera](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/Camera.kt) class is an abstract base that can be extended to create our own implementation of a camera. Luckily, we can use the [OrthographicCamera](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/Camera.kt#L339) implementation that is already offered.

The camera allows us to:

-   Move and rotate around the game world
-   Zoom in and out
-   Manage and update the viewport
-   project and unproject to and from screen and world spaces

### Orthographic Camera

By default, a _Camera_ doesn't contain or use a _Viewport_. It contains two properties that can be used to calculate the `projection` matrix: `virtualWidth` and `virtualHeight`.

```kotlin
val camera = OrthographicCamera(graphics.width, graphics.height)
```

When using a camera we want to make sure we call the `update()` method on it before doing any rendering to ensure it updates that its matrices are up to date. We then can use the `viewProjection` matrix in the _Camera_ class to render to a [SpriteBatch](/docs/2d/spritebatch).

```kotlin
val camera = OrthographicCamera(graphics.width, graphics.height)

onUpdate {
    val renderPass = ... // render pass releated setup
    camera.update()
    batch.use(renderPass, camera.viewProjection) {
        // we are using the cameras view projection matrix to render
    }
}
```

We can also update the `virtualWidth` and `virtualHeight` of the _Camera_ when the game window resizes:

```kotlin
onResize { width, height ->
    camera.virtualWidth = width
    camera.virtualHeight = height
}
```

## Using a Viewport

Instead of managing the size of the camera ourselves, we can use a _Viewport_ instead to handle the sizing. When creating a new _Viewport_ we can either pass in our own _Camera_ instance or let the viewport create its own which we then can reference.

```kotlin
val viewport = ExtendViewport(480, 270)
val camera: OrthographicCamera = viewport.camera
```

A viewport can be resized by using the `update()` method which will also update the _Camera_ instance:

```kotlin
onResize { width, height ->
    viewport.update(width, height)
}
```

## Types of Viewports

### Stretch Viewport

A viewport that supports using a virtual size (via [StretchViewport](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/util/viewport/ScalingViewports.kt#L34)). The virtual viewport is strechted to fit the screen. There are no black bars and the aspect ratio can change after scaling.

### Extend Viewport

A viewport that supports using a virtual size (via [ExtendViewport](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/util/viewport/ExtendViewport.kt)). The virtual viewport maintains the aspect ratio by extending the game world horizontally or vertically. The world is scaled to fit within the viewport and then the shorter dimension is lengthened to fill the viewport.

### Screen Viewport

A viewport that uses a virtual size that will always match the window size (via [ScreenViewport](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/util/viewport/ScreenViewport.kt)). No scaling happens along with no black bars appearing.
