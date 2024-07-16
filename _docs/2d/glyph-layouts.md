---
title: Glyph Layouts
permalink: /docs/2d/fonts/glyph-layouts
---

## Glyph Layout

Internally, a `FontCache` uses a [GlyphLayout](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/font/GlyphLayout.kt). The `GlyphLayout` handles are the measuring of the text as well as wrapping the text. We can create our own `GlyphLayout` to measure text if needed. The lines of text are then stored in a `GlyphRun` which holds the glyphs of the specified font for that line of text. This does not handle any sort of drawing or caching of data.

```kotlin
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()
val layout = GlyphLayout()
layout.setText(font, "My text", color = Color.WHITE, width = 0f, scaleX = 1f, scaleY = 1f, align = HAlign.LEFT, wrap = false)

println("width: ${layout.width} - height: ${layout.height}")

// iterate through the runs of the layout and print out each character
layout.runs.forEach { run ->
    val x = run.x
    val y = run.y
    run.glyphs.forEeach { glyph ->
        print(glyph.code.toChar())
    }
    println()
}
```
