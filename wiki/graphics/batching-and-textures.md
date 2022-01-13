---
title: Batching and Textures
---

An overview on reading images and drawing them in an optimized fashion via the `SpriteBatch` class.

## Overview

To draw an image in LittleKt, we first need to convert that image from its original format (e.g. PNG) and then upload it to the GPU. By doing that, we now have a `Texture` that we can use for drawing.

It is common to draw the same texture, or even portions of the same texture, multiple times. Defining multiple portions of the textures and uploading them to the GPU one at a time is inefficient. It is more efficient to define the portions of that textures and send them to the GPU all at once. This is called batching and is exactly what `SpriteBatch` handles.

A `SpriteBatch` is given a texture and coordinates of each portion of that texture to draw. It caches the geometry until it is ready to upload to the GPU. If a different texture is supplied than the last texture, then it will bind the last texture and submit the cached geometry to be drawn, and begins to cache geometry for the new texture.

## Texture

A [Texture](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Texture.kt) object handles the decoded data of an image file and uploading it to the GPU. If a `Texture` is created manually, we must then call the `prepare()` method which grabs the `GL` instance from the `Context` and uploads the image to the GPU.

### Reading a Texture

```kotlin
// 'readTexture()' automatically prepares a texture. We don't have to call texture.prepare() here.
val texture: Texture = resourcesVfs["texture.png"].readTexture()
```

### TextureSlice

A [TextureSlice](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/TextureSlice.kt) describes a rectangular portion inside a texture. This is useful for only drawing a portion of the texture.

```kotlin
val texture: Texture = resourcesVfs["texture.png"].readTexture()
val slice = TextureSlice(texture, x = 10f, y = 5f, width = 25f, height = 15f)
```

We also have a few utility extension for creating texture slices:

### A slice of the entire texture

```kotlin
val texture: Texture = resourcesVfs["texture.png"].readTexture()
val slice: TextureSlice = textures.slice()
```

### Slicing the texture into a 2D array

```kotlin
val texture: Texture = resourcesVfs["texture.png"].readTexture()
val slices: Array<Array<TextureSlice>> = texture.slice(sliceWidth = 16, sliceHeight = 16)
val hero: TextureSlice = slices[0][0]

val flattenedSlices = slices.flatten() // a single list of slices instead
```

### Slice up a texture with an added border of pixels

Sometimes we may find ourselves using portions of another slice of the texture bleed into another when rendering it. This is due to the way the GPU samples the texture and causes texture bleeding. One way we can solve this is by adding an extra pixels on the sides of each tile so when the GPU samples it won't accidentally get a sample of another slice we don't want.

LittleKt provides an easy way to add pixels to each tile at runtime:

```kotlin
val texture: Texture = resourcesVfs["texture.png"].readTexture()

// adds a 1 pixel border on each side of the each slice
val slices: List<TextureSlice> = texture.sliceWidthBorder(context, sliceWidth = 16, sliceHeight = 16, border = 1, mipmaps = true)
```

## SpriteBatch

A [SpriteBatch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/SpriteBatch.kt) batches the geometry for drawing a single texture into a single draw call. A `SpriteBatch` uses a [Mesh](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Mesh.kt) internally to render the geometry. A `Spritebatch` must either called `begin` and `end` methods or the `use` method to do any drawing. The drawing must be done between the calls of these methods.
``

```kotlin
val batch = SpriteBatch(context)

onRender {
    batch.use {
       // drawing logic goes here
    }

    // or we can use:

    batch.begin()
    // do drawing logic here
    batch.end()
}
```

`SpriteBatch` assumes the active texture unit is **0**. When using a custom shader or binding a texture ourself, we must ensure we reset the active texture unit by calling:

```kotlin
val gl: GL = context.gl
gl.activeTexture(GL.TEXTURE0)
```

### Drawing textures and texture slices

`SpriteBatch` contains many methods for drawing but the common draw methods are for drawing textures and slices of textures:

```kotlin
val batch = SpriteBatch(context)
val texture: Texture = resourcesVfs["texture.png"].readTexture()
val slices = texture.slice(16, 16)
val person = slices[0][0]

onRender {
    batch.use {
       // the draw method also contains a few more parameters such as origin, scale, rotation, colors, and flipping.
       // they all have a default value so we don't have to specify them.
       it.draw(texture, x = 50f, y = 25f)
       it.draw(person, x = 5f, y = 50f)
    }
}
```
