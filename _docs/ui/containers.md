---
title: Containers
permalink: /docs/ui/containers
---

# Using Containers

Using [anchors](/docs/ui/size-and-anchors) can be efficient enough to handle multiple resolutions. But as the UI gets more complex, they become difficult to use.

A way we can handle more complex and advanced layouts is by making use of [Containers](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/Container.kt).

## Container Layout

When a [Container](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/Container.kt) node is used, any [Control](<[Containers](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/Control.kt)>) nodes that are a child give up their ability to position themselves. The parent container will handle all of these nodes position and sizes. Manually changing the child nodes position or size will either be ignored or invalidated the next time the parent is resized.

When a container is resizes, all of its children are reositioned and resized as well:

![hBox container resize example](/assets/images/ui/hbox-container-resize.gif)

## Size Flags

When adding a control node to a container, the way a container treats a child depends mainly on their _size flags_. These can be set on each control node by using the `horizontalFlags` and `verticalFlags` properties.

```kotlin
hBoxContainer {
    button {
        text = "Button"
        horizontalSizeFlags = SizeFlag.FILL or SizeFlag.EXPAND
    }
    button {
        text = "Button 2"
        horizontalSizeFlags = SizeFlag.FILL or SizeFlag.EXPAND
    }
    button {
        text = "Button 3"
        horizontalSizeFlags = SizeFlag.FILL or SizeFlag.EXPAND
    }
}
```

Size flags are independent of vertical and horizontal sizing and not all containers make use of them:

-   **Fill**: Ensures the control _fills_ the designated area within the container. No matter if a control _expands_ or not, it will only _fill_ the designated area when this is toggled (control nodes use this by default)
-   **Expand**: Attempts to use as much space as possible in the parent container. Controls that don't expand will be pushed away by those that do. Between expanding controls, the amount of space they take from each other is determined by the _stretch ratio_.
-   **Shrink Center**: When _expanding_ (and not _filling_), try to remain at the center of the expanded area. By default, it remains at top or left.
-   **Stretch Ratio**: A ratio of how much expanded controls take up the available space in relation to each other. A control with a stretch ratio of `2` will take up twice as much available space with a control with `1`.

## Container Types

There are several out of the box container types:

### Box Containers

#### HBox

Arranges child controls horizontally while expanding vertically (via [HBoxContainer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/HBoxContainer.kt)).

#### VBox

Arranges child controls vertically while expanding horizontally (via [VBoxContainer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/VBoxContainer.kt))

### Center Container

Arranges child controls directly in the center (via [CenterContainer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/CenterContainer.kt)).

### Padded Container

Arranges child controls that are expanded toward the bounds (via [PaddedContainer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/PaddedContainer.kt)) with an additional padding that will be added to the margins which can be configured by the theme.

### Panel Container

A container that renders a _Drawable_ and expands its children to cover the whole area (via [PanelContainer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/ui/PanelContainer.kt)).

## Custom Container

It is also possible to create our own container. All we have to do is extend the `Container` class and implement logic on sorting the child controls and calculating size. Here is an example of implementing a container that centers its children:

```kotlin
class MyCustomContainer : Container() {
    override fun onSortChildren() {
        nodes.forEach {
            if (it is Control && it.enabled) {
                val newX = floor((width - it.combinedMinWidth) * 0.5f)
                val newY = floor((height - it.combinedMinHeight) * 0.5f)
                fitChild(it, newX, newY, it.combinedMinWidth, it.combinedMinHeight)
            }
        }
    }

    override fun calculateMinSize() {
        if (!minSizeInvalid) return

        var maxWidth = 0f
        var maxHeight = 0f

        nodes.forEach {
            if (it is Control && it.enabled) {
                if (it.combinedMinWidth > maxWidth) {
                    maxWidth = it.combinedMinWidth
                }
                if (it.combinedMinHeight > maxHeight) {
                    maxHeight = it.combinedMinHeight
                }
            }
        }

        _internalMinWidth = maxWidth
        _internalMinHeight = maxHeight
        minSizeInvalid = false
    }
}
```
