---
title: Polling
permalink: /docs/input/types/polling
---

Polling refers to checking the state of an input device. It is an easy way to check and process user input and will most likely suffice for most simple games.

## Polling anything

The `Context` object provides an `Input` that can be used to poll the current state of mouse, keyboards, and gamepads. The input can be accessed by the `context.input` property. To shorten it even more, a `ContextListener` delegates to the `Context` by default and allows us to access it just by the `input` property.

### Polling mouse/touch

There are a number of methods that are provided by polling the input.

To get the coordinates of the mouse we can do the following:

```kotlin
val x = input.x
val y = input.y
```

Once touch input is provided, we can grab coordinates of a specific pointer / finger:

```kotlin
val x = input.getX(Pointer.POINTER2)
val y = input.getY(Pointer.POINTER2)
```

#### Pressure

We can find the amount of pressure applied one a pointer which returns a value between `0` and `1`:

```kotlin
val pressure = input.getPressure(Pointer.POINTER1)
```

To determine which buttons are pressed on desktop:

```kotlin
val leftPressed = input.isTouched(Pointer.POINTER1)
val rightPressed = input.isTouched(Pointer.POINTER2)
```

### Polling Keyboard

Polling the keyboard is very simple and the `Input` class provides a bunch of util methods to make it easy.

Determine if a key is currently being pressed:

```kotlin
val down = input.isKeyPressed(Key.S)
```

Determine if a key was just pressed within the past frame:

```kotlin
val down = input.isKeyJustPressed(Key.S)
```

Determine if a key was just released with the past frame:

```kotlin
val justReleased = input.isKeyJustReleased(Key.S)
```

`Input` provides a bunch more of similar methods as the ones above for determining if multiple keys are pressed, not pressed, or any of them are pressed.

```kotlin
/**
 * Determines if any of the specified [keys] are currently pressed.
 * @return `true` if any of the keys are pressed; `false` otherwise.
 */
fun areAnyKeysPressed(vararg keys: Key): Boolean = keys.any { isKeyPressed(it) }

/**
 * Determines if all of the specified [keys] are currently pressed.
 * @return `true` if all of the keys are pressed; `false` otherwise.
 */
fun areAllKeysPressed(vararg keys: Key): Boolean = keys.all { isKeyPressed(it) }

/**
 * Determines if all of the specified [keys] are **NOT** currently pressed.
 * @return `true` if no keys are pressed; `false` otherwise.
 */
fun areNoKeysPressed(vararg keys: Key): Boolean = keys.none { isKeyPressed(it) }
```

### Polling Gamepads

Just like the mouse and keyboard we can also poll the state of gamepads. By default, it checks for the first gamepad connected but allows for checking for any additional by passing in the gamepad id.

Determining a the axis of either left or right joystick of the initial gamepad:

```kotlin
val xLeft = input.axisLeftX
val yLeft = input.axisLeftY
val xRight = input.axisRightX
val yRight = input.axisRightY
```

We can also determine the these values by using the `getGamepadJoystickDistanceXY` methods:

#### Joysticks

```kotlin
val leftAxis = input.getGamepadJoystickDistance(GameStick.LEFT)
val rightAxis = input.getGamepadJoystickDistance(GameStick.RIGHT)

val leftAxis2 = input.getGamepadJoystickDistance(GameStick.LEFT, gamepad = 1) // grabbing the axis from a different gamepad
val rightAxis2 = input.getGamepadJoystickDistance(GameStick.RIGHT, gamepad = 1)

val x = input.getGamepadJoystickXDistance(GameStick.LEFT)
val y = input.getGamepadJoystickYDistance(GameStick.LEFT)
```

#### Buttons

Very similar to how the keyboard polling works, `Input` provides the same pressed and released methods:

```kotlin
val justPressed = input.isGamepadButtonJustPressed(GameButton.XBOX_A)
val pressed = input.isGamepadButtonPressed(GameButton.XBOX_A)
val justReleased = input.isGamepadButtonJustReleased(GameButton.XBOX_X)
```

#### Pressure

The pressure of each button can be determines. For most buttons it will return either a `-1` or `1`. But for trigger buttons such as the `LT` or `RT` triggers on an Xbox controller they will return any value between `-1` to `1`.

```kotlin
val pressure = input.getGamepadButtonPressure(GameButton.LEFT_TRIGGER)
```

#### Iterating through multiple connected gamepads

The `Input` interface provides a list of connected gamepads that can be used for polling each individual gamepad.

```kotlin
input.connectedGamepads.forEach { gamepad ->
    val pressed = input.isGamepadButtonPressed(GameButton.PS_CROSS, gamepad = gamepad.index)
}
```
