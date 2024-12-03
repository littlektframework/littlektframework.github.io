---
title: Shape Renderer
permalink: /docs/2d/shape-renderer
---

## Overview

A [ShapeRenderer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/shape/ShapeRenderer.kt) performs drawing of shapes, lines, and paths using a [Batch](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/Batch.kt) instance for more optimal and performant drawing. Ported from the awesome library [ShapeDrawer](https://github.com/earlygrey/shapedrawer) by [earlygrey](https://github.com/earlygrey).

## ShapeRenderer

To create a `ShapeRenderer` we need to use an instance of a `Batch` and `TextureSlice`. The `TextureSlice` is typically a single 1x1 white pixel so that is can be easily colored as well as packed into a texture atlas with other textures.

### Creation

To create a `ShapeRenderer`:

```kotlin
val shapeRenderer = ShapeRenderer(batch, slice)
```

If a `TextureSlice` is not provided then the `ShapeRenderer` will default to `Textures.white`.

### Usage

Simplying call any of the draw methods between `Batch.begin()` and `Batch.end()` or in `Batch.use()`.

```kotlin
batch.use(renderPass)
    shapeRenderer.line(0f, 0f, 10f, 10f)
}
```

### Shapes

`ShapeRenderer` comes with a bunch of shapes out of the box as well as being able to construct our own polygons.

#### Lines

Lines are drawn using the `line()` methods.

This draws a line between two points. Line thickness can be specified as well as snapping the endpoints to the center of screen pixels.

#### Paths

Paths are drawn using the `path()` methods.

This draws lines between a list of points of a provided path. Line thickness, join type, and whether the patch is open (the first and last points are connceted) can be specified.

#### Polygons

Polygons are drawn using the `polygon()` and `filledPolygon()` methods.

A polygon can be drawn by specifying the number of sides, horizontal and vertical scales, rotation, and if drawing using lines, the line thickness and join type.

#### Circles and Ellipses

Circles and ellipses are drawn with `circle()`, `ellipse()`, `filledCircle()`, and `filledEillipse` methods.

These are drawn by using a regular polygon with a high number of sides in order for it to look smooth. The number of sides required is estimated based o nthe size of the ellipse and its eccentricity. The half-width and height, rotation, and line thickness can be specified.
A circle is the same as drawing and ellipse with the same width and height.

#### Rectangles

Rectangles are drawn using the `rectangle()` and `filledRectangle()` methods.

The width, height, rotation, and if drawing using lines, line thickness, and join types can be specified.

### Join Types

When multiple lines that share an endpoint it is possible to bevel the ends of the line so that thick lines fit together nicely and do not have any gaps at the joints.

#### None

There is no joining done and lines will draw over each other. This is apparent when using transparent lines.

#### Pointy

The corresponds to a standard miter joint and is drawn by stretching the corners of the line endpoints so that they sit flush. This requires additional calculations to find the points.

This is the default for polygons.

#### Smooth

This prevent lines from drawing over each other as well as filling in the gap of the elbow wit ha small triangle. This requires additional calcuations to fine the meeting points of the lines as well as an extra quad to be drawn per joint for the gap filling.

This is the dfeault for ellipses and paths.

### Pixel Snapping

`ShapeRenderer` offers snapping individual endpoints to the nearest pixel center points to prevent floating point rounding errors that may prevent certain pixels to not draw.

By default, `ShaperRenderer.snap` is turned off. If turned on, the `ShapeRenderer` will keep track of the size of a screen pixel in world coordinates and uses that to calculate the offset of the start and end points. This pixel size can be set manually by setting `ShapeRenderer.pixelSize` or using `ShapeRenderer.updatePixelSize()` to calculate it automatically using the current project and transformation matrices of the batch.

This is only used when calling `line()` and does not with with join types.
