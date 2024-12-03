---
title: NinePatch
permalink: /docs/2d/ninepatch
---

A [NinePatch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/NinePatch.kt) is an image that is sliced up into 9 patches in order to produce a clean panel of any size based on a small texture by splitting it into a 3x3 grid. The slices of the texture are then drawn and the sides are scaled horizontally or vertically and the center on both axes but doesn't scale or tile the corners.

## Creating a NinePatch

To create a `NinePatch` we must first load a `Texture` and pass it in to the ninepatch during construction.

We must define the amount of pixels from each edge of the texture that indicates the positions of the stretchable area. They don't have to be equal in value and can vary in size.

```kotlin
val texture = resourcesVfs["my_texuture_9.png"].readTexture()
val ninepatch = NinePatch(texture, left = 2, right = 2, top = 2, bottom = 2)
```

## Using a NinePatch

Once we have created a `NinePatch` using it is as simple as calling the `draw` method on and passing in a `Batch` instance.

```kotlin
val texture = resourcesVfs["my_texuture_9.png"].readTexture()
val ninepatch = NinePatch(texture, left = 2, right = 2, top = 2, bottom = 2)

batch.use(renderPass, camera.viewProjection) {
    ninepatch.draw(
        batch = it,
        x = 0f,
        y = 0f,
        width = 200f,
        height = 300f,
    )
}
```