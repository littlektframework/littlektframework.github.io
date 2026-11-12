---
title: Themes
permalink: /docs/0.12.0/ui/themes
---

While we can set certain properties of a [Control](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/ui/Control.kt) node to make it look the way we want, and in some cases it is easier, it can get difficult to handle when dealing with more advanced layouts and could be difficult to refactor.

Instead we can use a [Theme](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/Theme.kt) that handles rendering the correct drawables, colors, fonts, and even sizes. If you have used a _Control_ nodes that renders something to the screen then you have already used a theme without knowing it.

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
                text = "Nice!"
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
                text = "Nice!"
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

LittleKt has a flat dark theme built in that every _Control_ node will fallback to if it doesn't have a theme set. We can also replace the default theme with our own.

```kotlin
Theme.defaultTheme = myTheme // sets the default theme application wide
```

### Palettes

The default theme is built from a [ThemePalette](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/ThemePalette.kt). Use `ThemePalette.DARK` or `ThemePalette.LIGHT` and `copy` to change any color, such as the `accent`.

```kotlin
val lightTheme = createDefaultTheme(palette = ThemePalette.LIGHT)
val redTheme = createDefaultTheme(
    palette = ThemePalette.DARK.copy(accent = Color.fromHex("ff6b6b")),
    cornerRadius = 4
)
```

### sRGB

Palette colors are in sRGB. When rendering to an sRGB target, set `srgb` to convert them to linear. The `SceneGraph` already does this for the built-in default theme.

```kotlin
Theme.defaultTheme = createDefaultTheme(
    palette = ThemePalette.LIGHT,
    srgb = context.graphics.preferredFormat.srgb
)
```

## Creating a Custom Theme

Use the `theme { }` builder to set the values of each _Control_ type. If a value is missing, it will resort to either the parent _Control_ theme or the _default_ theme.

```kotlin
val myTheme = theme {
    defaultFont = myFont
    button {
        normal = FlatDrawable(Color.DARK_GRAY, cornerRadius = 4)
        hover = FlatDrawable(Color.GRAY, cornerRadius = 4)
        fontColor = Color.WHITE
        fontColorDisabled = Color.LIGHT_GRAY
    }
    label { fontColor = Color.WHITE }
    lineEdit {
        bg = FlatDrawable(Color.DARK_GRAY)
        caret = FlatDrawable(Color.WHITE).apply { minWidth = 1f }
        fontColorPlaceholder = Color.LIGHT_GRAY
    }
    progressBar {
        bg = FlatDrawable(Color.DARK_GRAY)
        fg = FlatDrawable(Color.GREEN)
    }
    scrollBars { grabber = FlatDrawable(Color.GRAY, cornerRadius = 3) }
    column { separation = 6 }
    row { separation = 6 }
    paddedContainer { padding(8) }
}
```

Setting a value to `null` unsets it. The typed scopes are:

-   `button`, `label`, `lineEdit`, `panel`, `panelContainer`, `progressBar`, `scrollContainer`
-   `vScrollBar`, `hScrollBar`, or `scrollBars` for both
-   `column` _(VBoxContainer)_ and `row` _(HBoxContainer)_
-   `paddedContainer`

### Other Types

For custom controls or values not covered by a scope, set the type with `type<T>` or by its class name with `type("Name")`.

```kotlin
val myTheme = theme {
    type<MyControl> {
        colors["outline"] = Color.RED
    }
    type("VScrollBar") {
        drawables[ScrollBar.themeVars.scroll] = FlatDrawable(Color.DARK_GRAY)
    }
}
```

Each type holds maps of [Drawables](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/resource/Drawable.kt), [Bitmap Fonts](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g2d/font/BitmapFont.kt), [Colors](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/Color.kt), and _Constants_:

-   **drawables**: backgrounds and states, such as a button's `normal` or `pressed`.
-   **fonts**: fonts used by the control.
-   **colors**: font colors, drawable colors, etc.
-   **constants**: padding sizes, boolean values _(0 or 1)_, etc.

### Extending a Theme

Pass a base theme to start from. Its values are kept unless they are set in the builder.

```kotlin
val myTheme = theme(Theme.defaultTheme) {
    button { normal = NinePatchDrawable(myNinePatch) }
    label { fontColor = null } // unset, falls back to the parent theme
}
```

The `extraDrawables`, `extraFonts`, `extraColors`, and `extraConstants` maps of `createDefaultTheme` still work as well.

```kotlin
val myTheme = createDefaultTheme(
    extraDrawables = mapOf(
        "Button" to mapOf(Button.themeVars.normal to NinePatchDrawable(myNinePatch))
    )
)
```

### Theme Variables

Each _Control_ has a static variable called `themeVars` which references an object that contains any amount of _String_ variables which are used for grabbing theme resources to render.

```kotlin
// Button.kt

// ...
class ThemeVars {
    val fontColor = "fontColor"
    val fontColorDisabled = "fontColorDisabled"
    val font = "font"
    val normal = "normal"
    val pressed = "pressed"
    val hover = "hover"
    val hoverPressed = "hoverPressed"
    val disabled = "disabled"
    val focus = "focus"
}

companion object {
    // ...
    val themeVars = ThemeVars()
}
```

### Theme Level Font

On top of setting fonts for specific controls, we can also set a default font for the entire theme by setting `defaultFont` in the builder.

The default theme uses `Fonts.defaultNoOutline`. Pass `defaultFont` to `createDefaultTheme` to change it.

What this does is, if a _Control_ requires a _BitmapFont_ and the specific value for that _Control_ is not available, it will resort to using the theme level font. See [control theme value order](#control-theme-value-order) for more info.
