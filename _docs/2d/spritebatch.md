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

A [SpriteBatch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/SpriteBatch.kt) batches the geometry for drawing a single texture into a single draw call. A `SpriteBatch` uses an [IndexedMesh](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/IndexedMesh.kt) internally to render the geometry. A `Spritebatch` must either called `begin` and `end` methods or the `use` method to do any drawing. The drawing must be done between the calls of these methods. A `SpriteBatch`, internally, uses the `SpriteBatchShader` which is a `SpriteShader`. This allows the batcher to send camera uniform updates to the shader. The camera uniform is a dynamic uniform shader, meaning if a different camera `viewProjection` is used, it will use the same shader module to render but with the updated uniform value. The size of the uniform buffer is dependent on the device's `minUniformBufferOffsetAlignment` limit and must be aligned to it. By default, the uniform buffer size will be calculated with the following formula, using a default camera dynamic size of 50, which can be changed.

```kotlin
(Float.SIZE_BYTES * 16)
    .align(device.limits.minUniformBufferOffsetAlignment)
    .toLong() * cameraDynamicSize
```

### Usage

```kotlin
val batch = SpriteBatch(context)

onUpdate {
    val renderPass = ... // render pass setup
    batch.use(renderPass) {
       // drawing logic goes here
    }

    // or we can use:

    batch.begin()
    // do drawing logic here
    batch.flush(renderPass)
    batch.end()
}
```

### Projection Matrix

We can also set the projection matrix of the _SpriteBatch_ that will be used in the shader to render the items. This is mainly used with a [camera](/docs/2d/cameras-and-viewports) but can be any matrix:

```kotlin
batch.use(renderPass, camera.viewProjection) {
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

onUpdate {
    val renderPass = ... // render pass setup
    batch.use(renderPass) {
       // the draw method also contains a few more parameters such as origin, scale, rotation, colors, and flipping.
       // they all have a default value so we don't have to specify them.
       it.draw(texture, x = 50f, y = 25f)
       it.draw(person, x = 5f, y = 50f)
    }
    renderPass.end()
    
    // release render pass & surface textures
}
```
