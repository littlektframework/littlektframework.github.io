---
title: Cursor
---

## Cursor

We can override the cursor image with our own provided image. We can do that by creating a new [Cursor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Cursor.kt) object and passing in a `Pixmap` as well as the cursors hot spot coordinates.

### Using own image

```kotlin
val cursorImage = resourcesVfs["cursor.png"].readPixmap()

// sets the hot spot to the middle of the cursor
val cursor = Cursor(cursorImage, (cursorImage.width * 0.5f).roundToInt(), (cursorImage.height * 0.5f).roundToInt())

context.graphics.setCursor(cursor)

onDispose {
    cursor.dispose() // we need to dispose if we are done with it
}
```

### System cursor

We can also override the cursor with a system defined cursor by passing in a [SystemCursor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/SystemCursor.kt) instead.

```kotlin
context.graphics.setCursor(SystemCursor.CROSSHAIR) // nothing to dispose here
```
