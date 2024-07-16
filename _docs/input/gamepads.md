---
title: Gamepads
permalink: /docs/input/gamepads
---

LittleKt supports for gamepads for both desktop and browser.

## Gamepads

LittleKt comes with a [GampadInfo](https://github.com/littlektframework/littlekt/blob/a97f8a04857006d2b74216c138c4b31156ea8433/core/src/commonMain/kotlin/com/littlekt/input/Input.kt#L164) class that handles storing the input state for a gamepad. On top of that, LittleKt also provides its own [GameButton](https://github.com/littlektframework/littlekt/blob/a97f8a04857006d2b74216c138c4b31156ea8433/core/src/commonMain/kotlin/com/littlekt/input/Input.kt#L128), [GameStick](https://github.com/littlektframework/littlekt/blob/a97f8a04857006d2b74216c138c4b31156ea8433/core/src/commonMain/kotlin/com/littlekt/input/Input.kt#L119), and [GameAxis](https://github.com/littlektframework/littlekt/blob/a97f8a04857006d2b74216c138c4b31156ea8433/core/src/commonMain/kotlin/com/littlekt/input/Input.kt#L123) tables with utilities for handling different controllers such as Xbox or Playstation.

```kotlin
val xboxA = GameButton.XBOX_A // points to GameButton.BUTTON0
val psX = GameButton.PS_CROSS // points to GameButton.BUTTON0

println(xboxA == psX) // prints true
```

### Gamepad Mapping

Gamepads also allow changing the mapping of the controller. By default, LittleKt provides the standard game mapping that SDL uses. To provide a custom gamepad mapping, we can just extend the `GamepadMapping` class and provide the button and axis order lists.

Standard gamepad mapping example:

```kotlin
open class StandardGamepadMapping : GamepadMapping() {
    companion object : StandardGamepadMapping()

    override val id = "Standard"

    override val buttonListOrder: List<GameButton> = listOf(
        GameButton.BUTTON0,
        GameButton.BUTTON1,
        GameButton.BUTTON2,
        GameButton.BUTTON3,
        GameButton.L1,
        GameButton.R1,
        GameButton.L2,
        GameButton.R2,
        GameButton.SELECT,
        GameButton.START,
        GameButton.L3,
        GameButton.R3,
        GameButton.UP,
        GameButton.DOWN,
        GameButton.LEFT,
        GameButton.RIGHT,
        GameButton.SYSTEM
    )

    override val axisListOrder: List<GameAxis> = listOf(
        GameAxis.LX,
        GameAxis.LY,
        GameAxis.RX,
        GameAxis.RY
    )
}
```

Change the gamepad mapping by updating the `mapping` value in a `GamepadInfo`:

```kotlin
gamepad.mapping = MyCustomGamepadMapping()
```
