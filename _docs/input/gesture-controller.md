---
title: Gesture Controller
permalink: /docs/input/gesture-controller
---

A [GestureController](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/input/gesture/GestureController.kt) is an [InputProcessor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/input/InputProcessor.kt) that handles input events and detects any gesture related events and emits them as a new event.

## Detecting Gestures

Using a `GestureController` is as simple as using an `InputProcessor` except that it expects a [GestureProcessor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/input/gesture/GestureProcessor.kt) as an input to handle gesture events. Gesture events can be seen as anything related to touching the screen such as pinch zooming, panning. fling scrolling, etc.

### GestureProcessor

The `GestureProcessor` is an interface that handles gesture events. The interface itself:

```kotlin
interface GestureProcessor {

    fun touchDown(screenX: Float, screenY: Float, pointer: Pointer): Boolean = false

    fun tap(screenX: Float, screenY: Float, count: Int, pointer: Pointer): Boolean = false

    fun longPress(screenX: Float, screenY: Float): Boolean = false

    fun fling(velocityX: Float, velocityY: Float, pointer: Pointer): Boolean = false

    fun pan(screenX: Float, screenY: Float, dx: Float, dy: Float): Boolean = false

    fun panStop(screenX: Float, screenY: Float, pointer: Pointer): Boolean = false

    fun zoom(initialDistance: Float, distance: Float): Boolean = false

    fun pinch(initialPos1: Vec2f, initialPos2: Vec2f, pos1: Vec2f, pos2: Vec2f): Boolean = false

    fun pinchStop() = Unit
}
```

Events:

-   `touchDown`: triggered when a pointer touches the screen.
-   `tap`: triggered when a "tap" occurs. A tap is when a pointer touches the screen and lets go of the same area of the screen without moving outsize the tap zone. A tap zone is a rectangular area around the initial tap position.
-   `longPress`: triggered when a touch is pressed for a certain duration.
-   `fling`: triggered when a pointer "flings" the screen by dragging and lifting the pointer. Repeats the velocity in pixels per second.
-   `pan`: triggered when a pointer is dragged over the screen.
-   `panStop`: triggered when panning finishes.
-   `zoom` triggered when two pointers perform a pinch zoom gesture.
-   `pinch`: triggered when two pointers perform a pinch gesture.
-   `pinchStop`: triggered when pinching is finished.

### Creating a `GestureController`

There is a handy extension method that allows us to create a `GestureController` and `GestureProcessor` and add it to the curernt contexts input all in one go.

```kotlin
class MyGame(context: Context) : ContextListener(context) {

    // override any of the methods in InputProcessor that we want to actually make use of.
    override suspend fun Context.start() {
        val processor = input.gestureController {
            // creates a new GestureController and a new GestureProcessor and adds the processor to the controller as well as adding the controller to the current context.
            onTap { screenX, screenY, count, pointer ->
                println("Pointer ${pointer.index} is tapping at $screenX,$screenY for a total of $count taps.")
            }
            onLongPress { screenX, screenY ->
                input.vibrate(100.milliseconds)
            }
        }

        onRelease {
            removeInputProcessor(processor) // we don't have to do this if we are closing the application
        }
    }
}
```
