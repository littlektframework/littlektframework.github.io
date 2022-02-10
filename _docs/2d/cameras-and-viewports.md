---
title: Camera and Viewports
permalink: /docs/2d/cameras-and-viewports
---

The _Camera_ class and _Viewport_ class will seem very familiar if one has every used **libGDX**. They work the same in **LittleKt**. The camera can be use to manipluate the game world without having to manually handle any matrices. The viewport is used in tandem with the camera which supports dealing with different screen sizes / resolutions and aspect ratios.

## Using a Camera

The [Camera](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Camera.kt) class is an abstract base that can be extended to create our own implementation of a camera. Luckily, we can use the [OrthographicCamera](https://github.com/littlektframework/littlekt/blob/363b5ceb97acb0d8c11880246a62c430c81221e6/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Camera.kt#L339) implementation that is already offered.

The camera allows us to:

-   Move and rotate around the game world
-   Zoom in and out
-   Manage and update the viewport
-   project and unproject to and from screen and world spaces

### Orthographic Camera

By default, a _Camera_ uses the default implementation of _Viewport_. This will stretch and shrink the items that are rendered on screen unless we change the cameras viewport to something else.

```kotlin
val camera = OrthographicCamera(graphics.width, graphics.height).apply {
    viewport = ScreenViewport(graphics.width, graphics.height)
}
```

When using a camera we want to make sure we call the `update()` method on it before doing any rendering to ensure it updates that its matrices are up to date. We then can use the `viewProjection` matrix in the _Camera_ class to render to a [SpriteBatch](/docs/2d/spritebatch).

```kotlin
val camera = OrthographicCamera(graphics.width, graphics.height).apply {
    viewport = ScreenViewport(graphics.width, graphics.height)
}

onRender {
    gl.clear(ClearBufferMask.COLOR_BUFFER_BIT)

    camera.update()
    batch.use(camera.viewProjection) {
        // we are using the cameras view projection matrix to render
    }
}
```

We can also update the _Viewport_ of the _Camera_ when the game window resizes:

```kotlin
onResize { width, height ->
    // this will update the viewport size and update the cameras matrices
    camera.update(width, height, context)
}
```

## Using a Viewport

When using a _Camera_, we are already indirectly using a _Viewport_. A _Camera_ manages its own _Viewport_ and can be manipulated directly on the camera itself.

```kotlin
// this will update the internal viewport to the following virtual sizes
camera.virtualWidth = 480
camera.virtualHeight = 270


viewport.virtualWidth = 480
viewport.virtualHeight = 480
```

Resizing a viewport is also done in the _Camera_ class but can also be done directly on the _Viewport_ itself:

```kotlin
onResize { width, height ->
    viewport.update(width, height, context)
}
```

### Multiple Viewports

When we have multiple viewports, we must make sure we to apply the _Viewport_ before rendering so that the `glViewport` is set.

```kotlin
viewport.apply(context)
// draw using first viewport
viewport2.apply(context)
// draw using the second viewport
```

If we are using a _Camera_ we can access the _Viewport_ directly:

```kotlin
camera.viewport.apply(context)
```

## Types of Viewports

### Stretch Viewport

A viewport that supports using a virtual size (via [StretchViewport](https://github.com/littlektframework/littlekt/blob/363b5ceb97acb0d8c11880246a62c430c81221e6/core/src/commonMain/kotlin/com/lehaine/littlekt/util/viewport/ScalingViewports.kt#L34)). The virtual viewport is strechted to fit the screen. There are no black bars and the aspect ratio can change after scaling.

### Fit Viewport

A viewport that supports using a virtual size (via [FitViewport](https://github.com/littlektframework/littlekt/blob/363b5ceb97acb0d8c11880246a62c430c81221e6/core/src/commonMain/kotlin/com/lehaine/littlekt/util/viewport/ScalingViewports.kt#L29)). The virtual viewport will maintain its aspect ratio while attempting to fit as much as possible onto the screen. Black bars may appear.

### Fill Viewport

A viewport that supports using a virtual size (via [FillViewport](https://github.com/littlektframework/littlekt/blob/363b5ceb97acb0d8c11880246a62c430c81221e6/core/src/commonMain/kotlin/com/lehaine/littlekt/util/viewport/ScalingViewports.kt#L39)). The virtual viewport will maintain its aspect ratio but in an attempt to fiill the screen parts of the viewport may be cut off. No black bars may appear.

### Extend Viewport

A viewport that supports using a virtual size (via [ExtendViewport](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/util/viewport/ExtendViewport.kt)). The virtual viewport maintains the aspect ratio by extending the game world horizontally or vertically. The world is scaled to fit within the viewport and then the shorter dimension is lengthened to fill the viewport.

### Screen Viewport

A viewport that uses a virtual size that will always match the window size (via [ScreenViewport](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/util/viewport/ScreenViewport.kt)). No scaling happens along with no black bars appearing.
