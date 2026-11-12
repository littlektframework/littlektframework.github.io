---
title: Modifiers
permalink: /docs/0.12.0/ui/modifiers
---

A [Modifier](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/ui/Modifier.kt) is an ordered chain of changes applied to a [Control](/docs/0.12.0/ui/controls) when it is built, similar to Jetpack Compose modifiers. The built-in modifiers can be found in [ModifierExt](https://github.com/littlektframework/littlekt/blob/master/scene-graph/src/commonMain/kotlin/com/littlekt/graph/node/ui/ModifierExt.kt).

## Using Modifiers

Start a chain with `Modifier` and pass it to any control builder with `modifier`:

```kotlin
button("Play", modifier = Modifier.expandWidth().minSize(120f, 40f))
```

Modifiers are applied before the builder's block, so the block can override them:

```kotlin
button("Play", modifier = Modifier.minSize(120f, 40f)) {
    minWidth = 200f
}
```

## Reusing Modifiers

Store a chain in a `val` and reuse or extend it:

```kotlin
val primary = Modifier.minSize(120f, 40f).fontColor(Color.WHITE)

button("Play", modifier = primary.expandWidth())
button("Quit", modifier = primary)
```

## Order

Modifiers apply from the outside in. When two modifiers set the same value on one control, the outer (leftmost) one wins. Anything before a wrapper, such as `padding`, applies to the wrapper and anything after it applies to the control inside:

```kotlin
// expands the padded wrapper
button("Play", modifier = Modifier.expandWidth().padding(8))

// expands the button inside the padded wrapper
button("Play", modifier = Modifier.padding(8).expandWidth())
```

## Wrappers

Wrap the control in another container:

```kotlin
label("Padded", modifier = Modifier.padding(8))
label("Padded", modifier = Modifier.padding(horizontal = 16, vertical = 8))
label("On a panel", modifier = Modifier.panel())
label("On a background", modifier = Modifier.background(FlatDrawable(Color.DARK_GRAY, cornerRadius = 6)))
```

## Layout

Every [layout shortcut](/docs/0.12.0/ui/size-and-anchors) is also a modifier:

```kotlin
column(modifier = Modifier.fillParent(10f)) {
    button("Play", modifier = Modifier.shrinkCenter(vertical = false))
}
```

## Row & Column Scopes

Children of a `row` or `hBoxContainer` get `RowScope` modifiers: `weight` shares the free width, `align(VAlign)` keeps the minimum height and aligns vertically, and `fillHeight` stretches to the full height:

```kotlin
row {
    label("Name", modifier = Modifier.align(VAlign.CENTER))
    lineEdit(modifier = Modifier.weight(2f))
    button("Save", modifier = Modifier.weight(1f))
}
```

Children of a `column` or `vBoxContainer` get `ColumnScope` modifiers: `weight` shares the free height, `align(HAlign)` aligns horizontally, and `fillWidth` stretches to the full width:

```kotlin
column {
    label("Title", modifier = Modifier.align(HAlign.CENTER))
    scrollContainer(modifier = Modifier.weight())
    button("Close", modifier = Modifier.align(HAlign.RIGHT))
}
```

These are only available directly inside that container's block. A nested `column` in a `row` uses its own scope.

## Stack Scope

Children of a `stack`, `panelContainer` or `paddedContainer` get `StackScope` modifiers: `align(HAlign, VAlign)`, `align(HAlign)` or `align(VAlign)` keep the minimum size on that axis and align it, while the other axis still fills. `fillWidth` and `fillHeight` are the default:

```kotlin
stack {
    textureRect { slice = background }
    label("Paused", modifier = Modifier.align(HAlign.CENTER, VAlign.CENTER))
    button("Resume", modifier = Modifier.align(HAlign.RIGHT).padding(4))
}
```

Placed before a wrapper, `align` applies to the wrapper, so `Modifier.align(HAlign.RIGHT).padding(4)` aligns the padded box.

## Scroll Scope

Children of a `scrollContainer` keep their minimum size by default. `ScrollScope` modifiers stretch them to at least the visible area, excluding visible scroll bars: `fillViewportWidth` so only the height scrolls, `fillViewportHeight` so only the width scrolls, and `fillViewport` for both:

```kotlin
scrollContainer {
    column(modifier = Modifier.fillViewportWidth()) {
        repeat(20) { label("Item $it") { horizontalAlign = HAlign.CENTER } }
    }
}
```

## Theme Overrides

Override [theme](/docs/0.12.0/ui/themes) values on a single control:

```kotlin
label("Warning", modifier = Modifier.fontColor(Color.RED))

button(
    "Play",
    modifier = Modifier
        .color(Button.themeVars.fontColorDisabled, Color.GRAY)
        .drawable(Button.themeVars.normal, FlatDrawable(Color.DARK_GRAY))
        .font(Button.themeVars.font, myFont)
)

column(modifier = Modifier.constant(BoxContainer.themeVars.separation, 10).theme(myTheme)) {
    label("Tinted", modifier = Modifier.tint(Color.LIGHT_BLUE))
}
```

## Other

```kotlin
button("Hidden", modifier = Modifier.visible(false))
button("Disabled", modifier = Modifier.enabled(false))
panel(modifier = Modifier.mouseFilter(Control.MouseFilter.IGNORE))
```

## Custom Modifiers

Custom modifiers are extension functions on `Modifier`. Combine existing modifiers:

```kotlin
fun Modifier.card() = panel().padding(8)
```

Or add a new `Modifier.Element` with `then`:

```kotlin
fun Modifier.named(name: String) = then(Modifier.Element { it.name = name })
```

Use a `Modifier.Wrapper` to wrap the control in another control:

```kotlin
fun Modifier.framed() = then(Modifier.Wrapper { control -> PanelContainer().apply { addChild(control) } })
```
