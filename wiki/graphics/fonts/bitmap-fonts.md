---
title: Bitmap Fonts
---

Bitmap fonts are supported in the [BMFont](https://www.angelcode.com/products/bmfont/) format. A [BitmapFont](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/font/BitmapFont.kt) can draw strings of text using its own internal cache or we can create our own cache using the specified font.

## Bitmap Font

### Loading

We can parse and bitmap font file and create a `BitmapFont` object using the following:

```kotlin
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()
```

### Drawing Text

Each `BitmapFont` object contains its own internal [BitmapFontCache](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/font/BitmapFontCache.kt) which is an extension of a [FontCache](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/font/FontCache.kt). When we draw directly with the font, it will store the geometry of the glyphs drawn internally. This will clear any existing text. If we want to draw strings of text at different positions and colors we will need to create our own `BitmapFontCache`.

Multi-line texts, wrapping, and horizontally aligning text are all supported. Wrapping works by specifying the max width that the area of a font should take up. If it exceeds it, the internal glyph layout will wrap the text.

#### Drawing directly with a `BitmapFont`:

```kotlin
val batch = SpriteBatch(context)
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()

batch.use {
    // we don't actually have to specify each parameter as most have default options.
    font.draw(batch, "This is my test", x = 5f, y = 5f, rotation = Angle.ZERO, color = Color.WHITE, targetWidth = 0f, align = HAlign.LEFT, wrap = false)
}
```

#### Creating our own `BitampFontCache`

We can create our own cache which we can add as much static text as we want without clearing existing data if we don't want to. We can create as many font caches as we want.

##### Adding text

```kotlin
val batch = SpriteBatch(context)
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()
val cache = BitmapFontCache(font)

// we add two lines of text in the cache which is stored until we either call 'setText' or 'clear'
cache.addText("This is my test", x = 5f, y = 5f)
cache.addText("This is another line", x = 50f, y = 5f)

batch.use {
    // draws any stored text data
    cache.draw(batch)
}
```

##### Setting text

```kotlin
val batch = SpriteBatch(context)
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()
val cache = BitmapFontCache(font)


cache.addText("This is my first line", x = 50f, y = 5f)

cache.setText("This is my test", x = 5f, y = 5f) // this will clear the data from the 'addText' method.

batch.use {
    // draws any stored text data
    cache.draw(batch) // will only draw "This is my test"
}
```

##### Clear text

```kotlin
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()
val cache = BitmapFontCache(font)

cache.clear() // clears any data
```

### Dispose of a Bitmap Font

Once we are done we can call the `dispose()` method on the `BitmapFont` object.

```kotlin
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()

onDispose {
    font.dispose() // font is no longer usable
}
```
