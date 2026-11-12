---
title: TTF Files and Rendering
permalink: /docs/0.12.0/2d/fonts/ttf
---

Bitmap fonts are baked at one size and blur when scaled. A [RasterFont](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/font/RasterFont.kt) rasterizes the outlines of a [TtfFont](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/font/TtfFont.kt) at the exact pixel size, so text stays sharp.

Glyphs are rasterized with anti-aliased coverage the first time they are used and packed into texture pages. Pages are added as they fill up.

## Loading

```kotlin
val ttf: TtfFont = resourcesVfs["MyFont.ttf"].readTtfFont()
val font: RasterFont = ttf.raster(device, 24f)
```

`raster()` also takes `gamma` (above `1` makes thin text heavier) and `filter` (`FilterMode.NEAREST` is sharpest when drawn at 1:1).

## Default Font

LittleKt bundles Barlow Condensed Medium (SIL Open Font License 1.1, see `FONT_LICENSE`). `Fonts.defaultTtf` is the `TtfFont` and `Fonts.defaultRaster` is it rasterized at 17px, the size of the bitmap `Fonts.default`. The default scene graph theme uses `Fonts.defaultRaster`.

```kotlin
val title = Fonts.defaultTtf.raster(device, 32f)
```

## Drawing Text

Draw with a [TextureFontCache](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/font/BitmapFontCache.kt). Pass `font.textures` when drawing, since pages may be added as new glyphs are rasterized.

```kotlin
val cache = TextureFontCache(font)
cache.setText(font, "Hello", x = 20f, y = 20f)

batch.use(renderPass) {
    cache.draw(it, font.textures)
}
```

Rasterize glyphs ahead of time instead of on first draw:

```kotlin
font.preload("0123456789")
```

Advances and kerning are rounded to whole pixels. Draw at whole pixel positions for the sharpest result. Kerning is read from the `kern` and `GPOS` tables.

## Sizes

Each pixel size is rasterized once and cached by the `TtfFont`. Request the size you will draw at, such as the logical size times the screen scale, instead of scaling a smaller size up.

```kotlin
ttf.rasterSizeStep = 2f // round requested sizes to 2px steps. default 1px, 0 for exact sizes
ttf.maxRasterFonts = 4 // keep at most 4 sizes. default null, no limit
ttf.rasterFontSizes // cached sizes, least recently requested first
ttf.releaseRasterFonts() // release every cached size
font.release() // release a single size
```

`rasterSizeStep` lets small scale changes reuse a cached size. Once over `maxRasterFonts`, the least recently requested size is released. When using a limit, request the font with `raster()` when drawing instead of holding on to one:

```kotlin
val font = ttf.raster(device, 24f)
cache.draw(batch, font.textures)
```

## Texture Fonts

`RasterFont` and `BitmapFont` both implement [TextureFont](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/font/TextureFont.kt):

-   **textures**: the texture of each page.
-   **forScale(scale)**: the font for drawing at `scale` pixels per unit. `RasterFont` returns the font for the scaled pixel size. `BitmapFont` returns itself. Draw it at `1 / scale` to keep the same size.

```kotlin
val sharp = font.forScale(1.5f) // 36px RasterFont for a 24px font
```

## Scene Graph

Theme fonts are `TextureFont`s, so a `RasterFont` can be used as a theme font:

```kotlin
val theme = createDefaultTheme(defaultFont = ttf.raster(device, 16f))
```

A theme's `defaultFont` applies to the controls under it. Controls pick the font for their canvas pixel scale, `Control.pixelScale`, and snap text to pixels. For example, an `ExtendViewport` UI drawn 1.5x bigger has a pixel scale of `1.5` and draws a 24px font, so text stays sharp when the window is resized.

## Limits

-   TrueType (`glyf`) outlines only. CFF `.otf` fonts are not supported.
-   No hinting.
-   No complex shaping.

The [GlyphRasterizer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/font/GlyphRasterizer.kt) is public for custom rasterizing.

## Release

```kotlin
onRelease {
    ttf.release() // releases every cached RasterFont
}
```
