---
title: Billboards
permalink: /docs/0.13.0/3d/billboards
---

Draws textured quads, text, and strips in a 3D scene, such as health bars, damage numbers, icons over units, beams, and trails. A
[BillboardBatch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/BillboardBatch.kt)
turns quads and text to face the camera and batches draws by texture.

Use a `BillboardBatch` for many small things that face the camera. For a 2D drawing on a fixed plane in the world, such as a sign, use a [SpriteBatch with depth](/docs/0.13.0/2d/spritebatch#drawing-in-3d).

## Setup

Set the formats to match the render pass, like a `ModelBatch`. Set `depthFormat` to `null` if the pass has no depth target.

```kotlin
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8)
val billboards =
    BillboardBatch(device).apply {
        colorFormat = graphics.preferredFormat
        depthFormat = depthTarget.format
        sampleCount = 1 // or 4
    }
```

Buffers start with room for `initialQuads` (`1024` by default) and grow as needed.

## Each Frame

Draw after opaque geometry. Billboards test against depth but don't write it. `begin` takes the camera to face, `flush` draws everything added since the last flush, and `end` finishes. `end` doesn't flush, so anything not flushed is dropped.

```kotlin
modelBatch.flush(renderPass, camera, dt)

billboards.begin(camera)
billboards.draw(icon, x, y + 2f, z, 0.5f, 0.5f)
billboards.drawText(font, "-120", x, y + 2.5f, z, 0.4f, Color.RED)
billboards.flush(renderPass)
billboards.end()
```

Flushing with more than `maxFlushesPerFrame` (`8` by default) in one frame needs a higher value.

## Quads

`draw` takes a `TextureSlice` or a whole `Texture`. Sizes are in world units. The origin is from the left and bottom, `0` to `1`, centered by default.

```kotlin
billboards.draw(
    slice,
    x, y, z,
    width = 1f,
    height = 1f,
    color = Color.WHITE,
    rotation = 45.degrees, // around the view direction
    originX = 0.5f,
    originY = 0f, // bottom at the position
)
```

### Modes

- `BillboardMode.SPHERICAL` faces the camera fully, the default.
- `BillboardMode.AXIS_Y` stays upright and only turns around world y. Good for name plates, health bars, and trees.

```kotlin
billboards.draw(tree, x, 0f, z, 2f, 4f, originY = 0f, mode = BillboardMode.AXIS_Y)
```

### Size in Pixels

`sizeInPixels = true` keeps the same size on screen at any distance. Width and height are then in pixels.

```kotlin
billboards.draw(icon, x, y + 3.5f, z, 32f, 32f, sizeInPixels = true)
```

### Health Bars

Draw a background, then the fill scaled by health. Set `originX = 0.5f / health` so the fill keeps its left edge in place.

```kotlin
billboards.draw(Textures.white, x, y, z, 1.2f, 0.16f, Color(0f, 0f, 0f, 0.6f), mode = BillboardMode.AXIS_Y)
billboards.draw(
    Textures.white,
    x, y, z,
    1.16f * health,
    0.12f,
    barColor,
    originX = 0.5f / health,
    mode = BillboardMode.AXIS_Y,
)
```

## Text

`drawText` takes any `TextureFont`. `size` is the font size in world units, or pixels with `sizeInPixels`. `originY` is from the bottom of the capital letters.

Bitmap and raster fonts blur up close. Use an [MsdfFont](/docs/0.13.0/2d/fonts/ttf#msdf-fonts) to stay sharp at any distance. Its `MsdfStyle` outline and glow are drawn too.

```kotlin
val font = Fonts.defaultTtf.msdf(device, 32f)
val namePlate = font.withStyle(MsdfStyle(outlineWidth = 0.08f))
val damageFont = font.withStyle(MsdfStyle(outlineWidth = 0.1f, outlineColor = Color(0.3f, 0f, 0f, 1f)))

billboards.drawText(namePlate, unit.name, x, y + 2.8f, z, 0.35f, mode = BillboardMode.AXIS_Y)
billboards.drawText(damageFont, amount.toString(), x, y, z, 0.5f, fadingColor)
```

For floating damage numbers, move each number up and fade its color over its life.

## Strips

A strip is a ribbon through a list of points that turns to face the camera. Each point has a width and color. The texture stretches along its length, and defaults to `Textures.white`.

```kotlin
billboards.beginStrip()
billboards.stripPoint(0f, 0.2f, 0f, 0.25f, Color(1f, 0.3f, 0.2f, 1f))
billboards.stripPoint(target.x, target.y, target.z, 0.05f, Color(1f, 0.8f, 0.4f, 1f))
billboards.endStrip()
```

### Trails

There is no trail type. A trail is a strip of recent positions. Keep them in a ring buffer and draw oldest to newest, tapering width and alpha.

```kotlin
val trail = FloatArray(TRAIL_POINTS * 3)
var head = 0
var count = 0

// each update
trail[head * 3] = tip.x
trail[head * 3 + 1] = tip.y
trail[head * 3 + 2] = tip.z
head = (head + 1) % TRAIL_POINTS
count = minOf(count + 1, TRAIL_POINTS)

// each draw
billboards.beginStrip()
for (i in 0 until count) {
    val index = (head - count + i + TRAIL_POINTS) % TRAIL_POINTS
    val t = i / (count - 1).coerceAtLeast(1).toFloat()
    color.set(0.3f, 0.8f, 1f, t)
    billboards.stripPoint(trail[index * 3], trail[index * 3 + 1], trail[index * 3 + 2], 0.3f * t, color)
}
billboards.endStrip()
```

## Blending and Depth

`blendState` and `depthTest` apply to the following draws, so they can change mid batch.

```kotlin
billboards.blendState = BlendState.Add // glowing beams and trails
// strips
billboards.blendState = BlendState.NonPreMultiplied // the default

billboards.depthTest = false // draw over geometry, such as a marker seen through walls
```

## Limits

- Draws aren't sorted. Overlapping transparent draws mix in the order they were added.
- Release the batch when done. It doesn't own textures or fonts.

```kotlin
onRelease { billboards.release() }
```

See the [BillboardsExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/BillboardsExample.kt) for health bars, name plates, damage numbers, an icon, a beam, and a trail.
