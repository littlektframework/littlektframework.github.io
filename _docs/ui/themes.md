---
title: Themes
permalink: /docs/ui/themes
---

While we can set certain properties of a [Control](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/Control.kt) node to make it look the way we want, and in some cases it is easier, it can get difficult to handle when dealing with more advanced layouts and could be difficult to refactor.

Instead we can use a [Theme](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/component/Theme.kt) that handles rendering the correct drawables, colors, fonts, and even sizes. If you have used a _Control_ nodes that renders something to the screen then you have already used a theme without knowing it.

## Using a Theme

Using a theme is dead simple. Assuming we have already created the theme we want, all we have to do is set the `theme` property on a _Control_ to our new theme. The beauty of this is we only have to set that property on the top-most _Control_ node we want to have the theme. Any children _Control_ nodes under it will use the theme by default.

```kotlin
sceneGraph(context) {
    control {
        theme = myTheme

        // these all have the same theme!
        vBoxContainer {
            button {
                text = "Hello!"
            }

            label {
                text = "Nice!
            }
        }
    }
}
```

Any changes to the theme property from its parent will propagate down to its children and will recalculate its size based on the new theme values.

### Multiple Themes

Being able to set the theme on the only on specific _Control_ nodes that need it is very advantageous. For instance, we can have a top-level _Control_ that uses our default theme. Then we could have a child _Control_ that requires another specific theme, such as a dialog box based theme. Anything that isn't defined in that dialog based theme resorts to the top-level theme.

```kotlin
sceneGraph(context) {
    control {
        theme = myDefaultTheme

        label { // uses myDefaultTheme
            text = "Title"
        }

        vBoxContainer { // children and itself use myDialogTheme
            theme = myDialogTheme

            button {
                text = "Hello!"
            }

            label {
                text = "Nice!
            }
        }
    }
}
```

### Overriding Theme Values

Sometimes it is not practical to have to create an entire separate theme just for a single _Control_. Instead what we can do is directly override the theme property value right on the _Control_ we need.

```kotlin
sceneGraph(context) {
    control {
        theme = myDefaultTheme

        label {
            text = "Title"
            font = myPixelFont // overrides theme Label.Font
        }
    }
}
```

### Control Theme Value Order

The order that a _Control_ determines a theme value to use is the following:

1. Checks for any overridden theme values.
2. Checks for a theme and the value on set specifically on itself.
3. Moves up the tree checking each parent for a theme and value until no more _Control_ nodes are available.
4. Checks the default theme set a `Theme.defaultTheme`.
5. And if all else fails, it will resort to either one of the _fallback_ values:
    - **Font**: `Theme.FALLBACK_FONT`
    - **Drawable**: `Theme.FALLBACK_DRAWABLE`
    - **Color**: `Color.WHITE`
    - **Constant**: `0`

## Default Theme

LittleKt has a default theme built in that every _Control_ node will fallback to if it doesn't have a theme set. We can also replace the default theme with our own.

```kotlin
Theme.defaultTheme = myTheme // sets the default theme application wide
```

We can also reuse the default theme and add our own overrides to it:

```kotlin
val myTheme = createDefaultTheme( // top-level function we can access just like this
    extraDrawables = mapOf(
        // override the "normal" button state drawable with our own ninepatch
        "Button" to mapOf(
            Button.themeVars.normal to NinePatchDrawable(myNinePatch)
        )
    )
)
control.theme = myTheme
```

## Creating a Custom Theme

Currently, the only way to create a custom theme is to directly create a _Theme_ object and map our values to the resource we would like to use. At some point in the future, there could be a way to define a theme using a structure text file of some sort that can be assmebled at runtime.

Each theme come with a few properties that maps a _Control_ theme variable to the value. We don't have to set each value for each _Control_ theme variable. If a value is missing, it will resort to either the parent _Control_ theme or the _default_ theme.

For example, this is what the default theme looks like:

```kotlin
val greyButtonNinePatch = NinePatch(
    Textures.atlas.getByPrefix("grey_button").slice,
    5,
    5,
    5,
    4
)
val panelNinePatch = NinePatch(
    Textures.atlas.getByPrefix("grey_panel").slice,
    6,
    6,
    6,
    6
)
val drawables = mapOf(
    "Button" to mapOf(
        Button.themeVars.normal to NinePatchDrawable(greyButtonNinePatch)
            .apply { modulate = Color.LIGHT_BLUE },
        Button.themeVars.normal to NinePatchDrawable(greyButtonNinePatch)
            .apply { modulate = Color.LIGHT_BLUE },
        Button.themeVars.pressed to NinePatchDrawable(greyButtonNinePatch)
            .apply { modulate = Color.LIGHT_BLUE.toMutableColor().also { it.scaleRgb(0.6f) } },
        Button.themeVars.hover to NinePatchDrawable(greyButtonNinePatch)
            .apply { modulate = Color.LIGHT_BLUE.toMutableColor().also { it.lighten(0.2f) } },
        Button.themeVars.disabled to NinePatchDrawable(greyButtonNinePatch)
            .apply { modulate = Color.LIGHT_BLUE.toMutableColor().also { it.lighten(0.5f) } },
    ),
    "Panel" to mapOf(
        Panel.themeVars.panel to NinePatchDrawable(panelNinePatch).apply {
            modulate = Color.LIGHT_BLUE
        }
    ),
    "ProgressBar" to mapOf(
        ProgressBar.themeVars.bg to NinePatchDrawable(panelNinePatch).apply {
            modulate = Color.DARK_BLUE
        },
        ProgressBar.themeVars.fg to NinePatchDrawable(panelNinePatch).apply {
            modulate = Color.LIGHT_BLUE.toMutableColor().also { it.lighten(0.5f) }
        }
    )
)

val fonts = mapOf()

val colors = mapOf(
    "Button" to mapOf(Button.themeVars.fontColor to Color.WHITE),
    "Label" to mapOf(Label.themeVars.fontColor to Color.WHITE)
)

val constants = mapOf()

Theme(
    drawables = drawables,
    fonts = fonts,
    colors = colors,
    constants = constants,
    defaultFont = defaultFont
)
```

### Theme Map Types

Each theme expects a map of [Drawables](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/component/Drawable.kt), [Bitmap Fonts](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/font/BitmapFont.kt), [Colors](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Color.kt), and _Constants_.

Each of these maps are mapped to a _String_ to another map of the specified types. For example, the _drawables_ map expects a _String_ that maps to another map of _String_ that maps to a _Drawable_.

The first _String_ value is the name of the _Control_ while the second _String_ value is the named of the _Control's_ theme variable.

```kotlin
val drawables = mapOf(
    "Button" to mapOf(
        Button.themeVars.normal to NinePatchDrawable(myNinePatch)
    )
)
```

-   **Drawables**: A map of drawables mapped by _Control_ type, mapped by variable name and value.
-   **Fonts**: A map of fonts mapped by _Control_ type, mapped by variable name and value.
-   **Colors**: A map of colors mapped by _Control_ type, mapped by variable name and value. This can include things like font colors, drawable colors, etc.
-   **Constants**: A map of constants mapped by _Control_ type, mapped by variable name and value. This can include things like padding sizes, boolean values _(0 or 1)_, etc.

Each _Control_ has a static variable called `themeVars` which references an object that contains any amount of _String_ variables which are used for grabbing theme resources to render.

```kotlin
// Button.kt

// ...
class ThemeVars {
    val fontColor = "fontColor"
    val font = "font"
    val normal = "normal"
    val pressed = "pressed"
    val hover = "hover"
    val hoverPressed = "hoverPressed"
    val disabled = "disabled"
}

companion object {
    // ...
    val themeVars = ThemeVars()
}
```

### Theme Level Font

On top of setting fonts for specific controls, we can also set a default font for the entire theme. We can do that by settings the `defaultFont` property on a _Theme_.

What this does is, if a _Control_ requires a _BitmapFont_ and the specific value for that _Control_ is not available, it will resort to using the theme level font. See [control theme value order](#control-theme-value-order) for more info.
