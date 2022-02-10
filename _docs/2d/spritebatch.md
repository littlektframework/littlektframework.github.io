---
title: SpriteBatch
permalink: /docs/2d/spritebatch
---

An overview on reading images and drawing them in an optimized fashion via the `SpriteBatch` class.

## Overview

To draw an image in LittleKt, we first need to convert that image from its original format (e.g. PNG) and then upload it to the GPU. By doing that, we now have a `Texture` that we can use for drawing.

It is common to draw the same texture, or even portions of the same texture, multiple times. Defining multiple portions of the textures and uploading them to the GPU one at a time is inefficient. It is more efficient to define the portions of that textures and send them to the GPU all at once. This is called batching and is exactly what `SpriteBatch` handles.

A `SpriteBatch` is given a texture and coordinates of each portion of that texture to draw. It caches the geometry until it is ready to upload to the GPU. If a different texture is supplied than the last texture, then it will bind the last texture and submit the cached geometry to be drawn, and begins to cache geometry for the new texture.

## SpriteBatch

A [SpriteBatch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/SpriteBatch.kt) batches the geometry for drawing a single texture into a single draw call. A `SpriteBatch` uses a [Mesh](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Mesh.kt) internally to render the geometry. A `Spritebatch` must either called `begin` and `end` methods or the `use` method to do any drawing. The drawing must be done between the calls of these methods.
``

```kotlin
val batch = SpriteBatch(context)

onRender {
    gl.clear(ClearBufferMask.COLOR_BUFFER_BIT)
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

### Projection Matrix

We can also set the projection matrix of the _SpriteBatch_ that will be used in the shader to render the items. This is mainly used with a [camera](/docs/2d/cameras-and-viewports) but can be any matrix:

```kotlin
batch.use(camera.viewProjection) {
    // we are using the cameras view projection matrix to render
}

```

### Drawing textures and texture slices

`SpriteBatch` contains many methods for drawing but the common draw methods are for drawing textures and slices of textures:

```kotlin
val batch = SpriteBatch(context)
val texture: Texture = resourcesVfs["texture.png"].readTexture()
val slices = texture.slice(16, 16)
val person = slices[0][0]

onRender {
    gl.clear(ClearBufferMask.COLOR_BUFFER_BIT)
    batch.use {
       // the draw method also contains a few more parameters such as origin, scale, rotation, colors, and flipping.
       // they all have a default value so we don't have to specify them.
       it.draw(texture, x = 50f, y = 25f)
       it.draw(person, x = 5f, y = 50f)
    }
}
```
