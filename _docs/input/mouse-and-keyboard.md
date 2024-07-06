---
title: Mouse and Keyboard
permalink: /docs/input/mouse-and-keyboard
---

LittleKt supports input for the mouse on desktop and browser and the keyboard.

## Mouse

The mouse input supports reporting the location of the current pointer as 2D coordinates relative to the origin of the upper left corner of the screen.

Mouse input also allows to determine if the left, right, or middle mouse buttons were pressed. As well as handling scrolling.

Mouse inputs can be [polled](/docs/input/types/polling) or processed via [events](/docs/input/types/event-based).

## Keyboard

LittleKt comes with its own key-code table ([source](https://github.com/littlektframework/littlekt/blob/a97f8a04857006d2b74216c138c4b31156ea8433/core/src/commonMain/kotlin/com/littlekt/input/Input.kt#L14)) which handles handling all the different key-codes on each platform. Key-code presses and releases can be queried via [polling](/docs/input/types/polling) as able to be processed via generated [events](/docs/input/types/event-based).
