---
title: Textures and TextureSlices
permalink: /wiki/2d/textures-and-texture-slices
---

# Texture

A [Texture](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Texture.kt) object handles the decoded data of an image file and uploading it to the GPU. If a `Texture` is created manually, we must then call the `prepare()` method which grabs the `GL` instance from the `Context` and uploads the image to the GPU.

### Reading a Texture

```kotlin
// 'readTexture()' automatically prepares a texture. We don't have to call texture.prepare() here.
val texture: Texture = resourcesVfs["texture.png"].readTexture()
```

# TextureSlice

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
