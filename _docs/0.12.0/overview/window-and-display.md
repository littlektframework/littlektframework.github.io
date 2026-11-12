---
title: Window and Display
permalink: /docs/0.12.0/overview/window-and-display
---

`context.window` is a low-level [Window](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/Window.kt) API: query, change, and listen. Settings menus, presets, and saving are left to the game or engine.

See the [DisplaySettingsExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/ui/DisplaySettingsExample.kt) for everything on this page in one place.

## Capabilities

Check `window.capabilities` before offering an option. `WindowCapabilities` has `resize`, `move`, `minimize`, `borderless`, `fullscreen`, `monitorSelection`, and `closeRequests`.

```kotlin
val caps = window.capabilities
fullscreenButton.disabled = !caps.fullscreen
```

## Window Modes

`window.mode` is the current `WindowMode`. `setMode` returns `false` if the mode isn't supported.

```kotlin
val monitor = window.currentMonitor ?: window.primaryMonitor!!

window.setMode(WindowMode.Windowed)
window.setMode(WindowMode.Borderless(monitor))
window.setMode(WindowMode.Fullscreen(monitor, monitor.currentMode))
```

- `Windowed`: a regular decorated window.
- `Borderless(monitor)`: an undecorated window covering the monitor, without changing its video mode.
- `Fullscreen(monitor, videoMode)`: exclusive fullscreen using the video mode.

### Start Mode (Desktop)

```kotlin
createLittleKtApp {
    windowMode = StartWindowMode.BORDERLESS // WINDOWED, BORDERLESS, or FULLSCREEN on the primary monitor
}
```

## Monitors and Video Modes

`window.monitors`, `window.primaryMonitor`, and `window.currentMonitor` (the monitor the window is mostly on) return `Monitor` data classes.

```kotlin
data class Monitor(
    val id: Long,
    val name: String,
    val x: Int,
    val y: Int,
    val contentScale: Float,
    val currentMode: VideoMode,
    val modes: List<VideoMode>,
)

data class VideoMode(val width: Int, val height: Int, val refreshRate: Int) // refreshRate is 0 if unknown
```

```kotlin
window.monitors.forEach { monitor ->
    monitor.modes.forEach { println("${monitor.name}: ${it.width}x${it.height}@${it.refreshRate}") }
}
```

## Window State

- `title`: read and write.
- `x`, `y`: position in screen coordinates.
- `width`, `height`: logical size.
- `contentScale`: back buffer to logical ratio, such as `2` on a high DPI display.
- `focused`, `minimized`, `maximized`.

```kotlin
window.title = "My Game"
window.setSize(1280, 720) // requires resize
window.setPosition(100, 100) // requires move
window.setSizeLimits(640, 360, null, null) // null for no limit, requires resize

window.minimize() // requires minimize
window.maximize() // requires resize
window.restore()
window.focus()
```

## Events

Each callback returns a function to unsubscribe, like the other [Context](/docs/0.12.0/overview/context-and-contextlistener) callbacks.

```kotlin
onFocusChanged { focused -> }
onMinimizedChanged { minimized -> }
onContentScaleChanged { scale -> }
onWindowModeChanged { mode -> } // includes changes by the user, such as leaving fullscreen
onMonitorsChanged { monitors -> }
onCloseRequested { false } // keeps the window open, desktop only (closeRequests)
```

`onCloseRequested` closes only if every callback returns `true`.

### Resizing

`onResize` runs once at the start of the next frame, no matter how many resize events happened. On Windows, frames keep drawing while the window is being resized.

## Vsync

Pick a present mode from `graphics.surfaceCapabilities.presentModes`. Later `configureSurface()` calls, such as on resize, keep the chosen mode. `graphics.presentMode` is the current one.

```kotlin
if (PresentMode.MAILBOX in graphics.surfaceCapabilities.presentModes) {
    graphics.configureSurface(presentMode = PresentMode.MAILBOX)
}
```

## Frame Rate Limit

```kotlin
frameRateLimit = 60 // null for no limit
```

The limit is on top of any limit from the present mode.

## Web Limits

- The canvas follows the page, so `setSize`, `setPosition`, `minimize`, and `maximize` do nothing.
- Only `Windowed` and `Borderless` are supported. `Borderless` is browser fullscreen and must be requested from a user input event, such as a click. The browser may still refuse it.
- There is a single monitor named `"Screen"`.
- The present mode is always `FIFO`.
- `frameRateLimit` works by skipping animation frames.
- No close requests.
