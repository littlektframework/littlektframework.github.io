---
title: Drawables
permalink: /docs/ui/drawables
---

A [Drawable](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/component/Drawable.kt) is an interface that provides a draw method that takes in a `SpriteBatch`, position, scale, rotation, and color. The impelementation can draw anything it wants such as texture slices, nine patches, etc. Drawables are used in `Control` nodes for certain things such as backgrounds, foregrounds, and general themeing.

A `Drawable` contains properties for setting a minimum size, margins, and a color.

## Types

-   [EmptyDrawable](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/component/EmptyDrawable.kt): Doesn't render anything. All the margins and sizes are set to zero. This is great for drawables that can't be null.

-   [NinePatchDrawable](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/component/NinePatchDrawable.kt): Renders a `NinePatch`.
-   [TextureSliceDrawable](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/component/TextureSliceDrawable.kt): Renders a `TextureSlice`.
