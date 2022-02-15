---
title: Create Input Bindings
permalink: /docs/input/create-input-bindings
---

Using direct checks against `Input` for certain keys that have been pressed or if a certain button on a gamepad was used and then doing an action as a result of that event can work just fine.

But what if we wanted to define our own input types that can have keys, gamepad buttons, and such bound to that one type so that when a player uses that action we can react without having to do all of the verbose checks.

## InputMultiplexer

The [InputMultiplexer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/input/InputMultiplexer.kt) is a class that handles key, game buttons, and game axis inputs and converts them into a single custom input signal type. The multiplexer is also an [InputProcessor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/input/InputProcessor.kt).

Using the multiplexer is easy and a one time setup. All we have to do is define our own `InputType` that we want to use as the signal and then add use it to add bindings to the multiplexer.

### Create a Multiplexer

For this example, we are going to create bindings that allows the user to run around using either the **WASD**, the arrow keys, or a gamepad along with adding a simple _jump_ binding.

The first thing we need to do is create our own input type. For this we are just going to create an enum with a few values. A value for each action we want to define. We can also add values for defining certain axis and vectors (2 axis combined).

```kotlin
enum class GameInput {
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
    HORIZONTAL, // an axis
    VERTICAL, // an axis
    MOVEMENT, // movement vector
    JUMP
}
```

Next is to create the `InputMultiplexer` and then adding the bindings. We must also be sure to add the instance of the multiplexer to the list of input processors using `Context.input`.

```kotlin
val controller = InputMultiplexer<GameInput>(input).also {
    input.addInputProcessor(it)
}
```

### Create a Binding

Now that we have our multiplexer setup we can finally create a binding. We can use the `addBinding()` method on the multiplexer by passing in the input type value and passing in a few list of bindings from keyboard and gamepad.

```kotlin
// the 'A' and 'left arrow' keys and the 'x-axis of the left stick' with trigger the 'MOVE_LEFT' input type
controller.addBinding(GameInput.MOVE_LEFT, listOf(Key.A, Key.ARROW_LEFT), axes = listOf(GameAxis.LX))

// now lets define the rest of the movement
controller.addBinding(GameInput.MOVE_RIGHT, listOf(Key.D, Key.ARROW_RIGHT), axes = listOf(GameAxis.LX))
controller.addBinding(GameInput.MOVE_UP, listOf(Key.W, Key.ARROW_UP), axes = listOf(GameAxis.LY))
controller.addBinding(GameInput.MOVE_DOWN, listOf(Key.S, Key.ARROW_DOWN), axes = listOf(GameAxis.LY))

// define jumping with a key and a gamepad button
controller.addBinding(GameInput.JUMP, listOf(Key.SPACE), listOf(GameButton.XBOX_A))
```

### Use a Binding

We can now use the binding, similarly to how we would check if a key was used normally, by checking if the input signal is "_pressed_" or "_down_".

```kotlin
// check if JUMP is pressed so we can make our hero jump
if (controller.pressed(GameInput.JUMP)) {
    hero.y -= 25f
}
```

We can use the following methods:

-   `down()`: checks to see if the input type is currently "down" for any inputs. This doesn't trigger for a `GameAxis`.
-   `pressed()`: checks to see if the input type was just "pressed" for any inputs. This doesn't trigger for a `GameAxis`.
-   `released()`: checks to see if the input type was just "released" for any inputs. This doesn't trigger for a `GameAxis`.
-   `strength()`: returns the strength / pressure of the input type. A `Key` or a `GameButton` will return either a `-1`, `0`, or a `1`. A `GameAxis` will return anything between `-1` to `1`.
-   `dist()`: takes the absolute value of `strength()`

### Create an Axis

If we are using inputs that share the same axis (horizontally or vertically) we could combine these inputs into a single axis which we then can query. For our movement code, we have the `HORIZONTAL` and `VERTICAL` axes defined in our `GameInput` enum. We must define the input types that determine the _postive_ and _negative_ directions of our axis. For example, for our horizontal axis, the postive side would be to the _right_ and the negative side to the _left_ which matches the coordinate system.

```kotlin
// creates an axis based off the RIGHT and LEFT input types
controller.addAxis(GameInput.HORIZONTAL, GameInput.MOVE_RIGHT, GameInput.MOVE_LEFT)

// creates an axis based off the DOWN and UP input types
controller.addAxis(GameInput.VERTICAL, GameInput.MOVE_DOWN, GameInput.MOVE_UP)
```

### Using an Axis

We can query the strength of an axis which will returns a float which a value between `-1` and `1`.

```kotlin
val horizStrength = controller.axis(GameInput.HORIZONTAL)
val vertStrength = controller.axis(GameInput.VERTICAL)

// using the axes to move our hero
hero.x += horizStrength * speed
hero.y += vertStrength * speed
```

### Create a Vector

We can take it another step further we can take two axes that are related and combine them to create a _vector_. This _vector_ is just the calculation of the _strength_ of each invidiual axis combined and returns the result as a `Vec2f`. We need to define the postive and negative directions for each axis.

```kotlin
controller.addVector(
    GameInput.MOVEMENT,
    GameInput.MOVE_RIGHT,
    GameInput.MOVE_DOWN,
    GameInput.MOVE_LEFT,
    GameInput.MOVE_UP
)
```

### Using a Vector

We can query the strength of the vector which returns a `Vec2f` with the `xy` having a value between `-1` and `1`.

```kotlin
val dir = controller.vector(GameInput.MOVEMENT)
hero.x += dir.x * speed
hero.y += dir.y * speed
```

### All together now

If you have been following the above, you should have something that looks like this:

```kotlin
enum class GameInput {
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
    HORIZONTAL, // an axis
    VERTICAL, // an axis
    MOVEMENT, // movement vector
    JUMP
}

val controller = InputMultiplexer<GameInput>(input).also {
    input.addInputProcessor(it)
}

init {
    controller.addBinding(GameInput.MOVE_LEFT, listOf(Key.A, Key.ARROW_LEFT), axes = listOf(GameAxis.LX))
    controller.addBinding(GameInput.MOVE_RIGHT, listOf(Key.D, Key.ARROW_RIGHT), axes = listOf(GameAxis.LX))
    controller.addBinding(GameInput.MOVE_UP, listOf(Key.W, Key.ARROW_UP), axes = listOf(GameAxis.LY))
    controller.addBinding(GameInput.MOVE_DOWN, listOf(Key.S, Key.ARROW_DOWN), axes = listOf(GameAxis.LY))

    controller.addBinding(GameInput.JUMP, listOf(Key.SPACE), listOf(GameButton.XBOX_A))

    controller.addVector(
        GameInput.MOVEMENT,
        GameInput.MOVE_RIGHT,
        GameInput.MOVE_DOWN,
        GameInput.MOVE_LEFT,
        GameInput.MOVE_UP
    )
}

override suspend fun Context.start() {
    onRender { dt ->
        val dir = controller.vector(GameInput.MOVEMENT)
        // ...
    }
}
```
