---
title: Nodes
permalink: /docs/scene-graph/nodes
---

There are three main implemenations of nodes in the scene graph that LittleKt offers. Those three are the base [Node](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/Node.kt), a 2D based node [Node2D](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/Node2D.kt), and the user interface module of nodes. We will be reviewing `Node` and `Node2D` here. Check out [The User Interface](/docs/ui/the-user-interface) if you want to learn more on the UI.

## Node

The `Node` contains the base implementation that is used by all nodes in a scene graph. This contains lifecycle methods, render methods, adding/removing children, and any hiearchy changes.

A `Node` can contain one or more [Signal](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/util/signals.kt) types which can be used to subscribe to certain events that the node can emit.

For example, the `Node` class contains the following signals:

-   `onReady`: is emitted when the `ready()` callback is invoked
-   `onRender`: is emitted when the `render()` callback is invoked
-   `onDebugRender`: is emitted when `onDebugRender()` callback is invoked
-   `onPreUpdate`: is emitted when `preUpdate()` callback is invoked
-   `onUpdate`: is emitted when `update()` callback is invoked
-   `onPostUpdate`: is emitted when `postUpdate()` callback is invoked
-   `onFixedUpdate`: is emitted when `fixedUpdate()` callback is invoked

These signals can allow us to subscribe to these node lifecycle events without having to create a new class that inherits `Node`. This is useful if we want to do something simple with a node without having to go through all the trouble of creating a specific node to do so.

A `Node` can also add and remove children directly:

-   `addChild(node)`: will set the parent of the specified node to this node
-   `addChildren(nodes)`: adds a list of children to this node
-   `removeChild(node)`: will remove this node as the parent from the child node

We can also change the parent of a node:

-   `parent(node?)`: set this nodes parent to the new node. The parent can also be null.

### Custom Nodes

We can create our own custom nodes by creating a new class that inherits from `Node`.

```kotlin
class NewNode : Node {
    var health = 5

    override fun update(dt: Duration) {
        super.update(dt)
        // do something?
    }

}
```

If we want our new node to follow the same DSL pattern when creating a graph as the other nodes we can add something like this outside of the class:

```kotlin
// we want both of these - one for creating inside a scene graph context and the other inside a node context

inline fun NewNode.newNode(callback: @SceneGraphDslMarker NewNode.() -> Unit = {}) =
    NewNode().also(callback).addTo(this)

inline fun SceneGraph.newNode(callback: @SceneGraphDslMarker NewNode.() -> Unit = {}) = root.newNode(callback)
```

If we don't want to spend the time creating these new DSL methods, then we can use a DSL method that accepts another node type instead:

```kotlin
val scene = sceneGraph(context) {
    node(NewNode()) { // using the existing Node method instead
        health = 10
    }

    newNode { // using our newly created methods instead
        health = 10
    }
}
```

## CanvasItem and Node2D

The `CanvasItem` class (and the `Node2D` class which extends `CanvasItem`) contains an implementation on transforming a node in 2D space. The includes position, rotation, and scale. We have access to the local and global versions of these components. Making a change to any of these properties will dirty the hiearchy and update it's children.

```kotlin
val scene = sceneGraph(context) {
    node2d {
        x = 10f // local position

        node2d {
            x = 10f // local position

            onReady += {
                println(globalX) // outputs 20
            }
        }

        node2d {
            globalX = 5f
        }
    }
}
```

If a `Node2D` is a child to a base `Node`, it will not receive any 2D transformation hierachy updates. This includes if the base nodes parent is also a `Node2D`. This is due to the fact that a `Node` does not have the information to pass along the information to update a Node2D without specifically having to determine if any of its children are in fact a `Node2D`. Instead, the `Node2D` will assume it is a top-level `Node2D` and will act as so.

```kotlin
val scene = sceneGraph(context) {
    node {
        node2d {
            x = 10f
            rotation = 90.degrees

            node {
                node2d {
                    x = 10f

                    onReady += {
                        println(globalX) // outputs 10
                        println(globalRotation.degrees) // outputs 0
                    }
                }
            }
        }
    }
}
```

By design, the `position`, `globalPosition`, `scale`, and `globalScale` properties return an immutable `Vec2f`. This prevents us from accidentally updating the vector directly which would skip over needing to update the hiearchy. If we want to set a component of the vector directly, we can use the `x` and `y` properties instead:

-   `position`: local position immutable vector
-   `x`: local position x
-   `y`: local position y
-   `globalPosition`: global position immutable vector
-   `globalX`: global position x
-   `globalY`: global position y
-   `scale`: local scale immutable vector
-   `scaleX`: local scale x
-   `scaleY`: local scale y
-   `globalScale`: global scale immutable vector
-   `globalScaleX`: global scale x
-   `globalScaleY`: global scale y

### Render Sorting

A [Node2D] contains an option to sort it's child nodes by their y-position setting the `ySort` property to `true`. All this simply does is set the `nodes.sort` property to the internal `SORT_BY_Y` comparator.

We can use `nodes.sort` to set our own render sorting while keeping the same update order. By default, rendering is done by tree order, top to bottom.

```kotlin
val SORT_BY_Y: Comparator<Node> = Comparator { a, b ->
    if (a is CanvasItem && b is CanvasItem) {
        return@Comparator a.globalY.compareTo(b.globalY)
    }
    if (a is CanvasItem) {
        return@Comparator 1
    }
    if (b is CanvasItem) {
        return@Comparator -1
    }
    return@Comparator 0
}

node2d {
    nodes.sort = SORT_BY_Y
}
```

### Material

A `CanvasItem` contains [Material](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/render/Material.kt) instance that can be used to set shaders, blend modes, and depth/stencil modes. The `SceneGraph` handles any changes of the material of a `CanvasItem` which will flush the current batch thus increasing by a draw call.

```kotlin
node2d {
    material.blendMode = BlendMode.Add
    material.depthStencilMode = DepthStencilMode.StencilWrite

    // or we can set shader
    material = Material(ShaderProgram(MyFragmentShader(), MyVertexShader()))
```

#### Blend Mode Types

All the blend modes that can be used in a material are all under the [BlendMode](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/render/BlendMode.kt) class. Each type is a singleton object that can be accessed directly as so: `BlendMode.Alpha`.

-   `Alpha`
-   `Opaque`
-   `NonPreMultiplied`
-   `Add`
-   `Subtract`
-   `Difference`
-   `Multiply`
-   `Lighten`
-   `Darken`
-   `Screen`
-   `LinearDodge`
-   `LinearBurn`

#### Depth/Stencil Mode Types

All the blend modes that can be used in a material are all under the [DepthStencilMode](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/render/DepthStencilMode.kt) class. Each type is a singleton object that can be accessed directly as so: `DepthStencilMode.None`.

-   `Default`
-   `DepthRead`
-   `None`
-   `StencilWrite`
-   `StencilRead`

## CanvasLayer

A `CanvasLayer` node is the node that contains an `OrthographicCamera` that is used for rendering any children nodes as well as a `Viewport`. This node can be used to render nodes using different viewport and camera dimensions and positions. For example, this can be useful when we want to separate rendering a high resolution UI with a low resolution game. Due note that the based `CanvasLayer` node does **NOT** apply the _Viewport_ before rendering. Setting any viewport properties will have no affect. We can either extend and override the render method of the `CanvasLayer` or use the _ViewportCanvasLayer_ node below to use the viewport.

```kotlin
val scene = sceneGraph(context) {
    canvasLayer {
        node2d {
           // render my game nodes based on the canvasLayer camera!
        }
    }
    control {
        name = "UI
        // render my UI based on the scene graph viewport!
    }
}
```

### ViewportCanvasLayer

A `ViewportCanvasLayer` is a `CanvasLayer` node that handles updating the viewport and uses it to render its children. Due note, that the DSL method to create a _ViewportCanvasLayer_ is called `viewport`!

```kotlin
val scene = sceneGraph(context) {
    viewport {
        viewport = ExtendViewport(480, 270)
        // any children now will be rendered using the viewport above!

        node2d {
           // render my game nodes based on the viewport.
        }
    }
    control {
        name = "UI
        // render my UI based on the scene graph viewport!
    }
}
```

### FrameBufferNode

A `FrameBufferNode` is another `CanvasLayer` node that renders any of its children to a frame buffer of a specified size.

```kotlin
val scene = sceneGraph(context) {
    val fbo = frameBuffer {
        width = 480
        height = 270

        node2d {
            // render in frame buffer
        }
    }

    // we still need to render the FBO. To do so we can subscribe to the FBO onFboChanged signal.
    node2d {
        var slice: TextureSlice? = null
        // subscribe to the FBO node whenever the FBO is changed
        fbo.onFboChanged.connect(this) { fboTexture ->
            slice = fboTexture.slice() // create new slice from the FBO texture
        }

        onRender += { batch, camera, shapeRenderer ->
            slice?.let {
                batch.draw(
                    it,
                    x = 0,
                    y = 0,
                    flipY = true
                )
            }
        }
    }
}
```
