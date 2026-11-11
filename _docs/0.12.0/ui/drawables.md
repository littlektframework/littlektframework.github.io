---
title: Drawables
permalink: /docs/0.12.0/ui/drawables
---

A [Drawable](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/Drawable.kt) is an interface that provides a draw method that takes in a `SpriteBatch`, position, scale, rotation, and color. The impelementation can draw anything it wants such as texture slices, nine patches, etc. Drawables are used in `Control` nodes for certain things such as backgrounds, foregrounds, and general themeing.

A `Drawable` contains properties for setting a minimum size, margins, and a color.

## Types

-   [EmptyDrawable](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/EmptyDrawable.kt): Doesn't render anything. All the margins and sizes are set to zero. This is great for drawables that can't be null.

-   [NinePatchDrawable](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/NinePatchDrawable.kt): Renders a `NinePatch`.
-   [TextureSliceDrawable](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/TextureSliceDrawable.kt): Renders a `TextureSlice`.
-   [FlatDrawable](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/FlatDrawable.kt): Renders a flat rounded rectangle with an optional border.

## Flat Drawable

A `FlatDrawable` is a rounded rectangle with an optional border, similar to Godot's `StyleBoxFlat`. No art is needed. The margins default to the larger of `cornerRadius` and `borderWidth`.

```kotlin
val drawable = FlatDrawable(
    color = Color.DARK_GRAY,
    borderColor = Color.LIGHT_GRAY,
    borderWidth = 1,
    cornerRadius = 4,
    margin = 6f
)
```
