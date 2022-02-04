---
title: Nodes
permalink: /wiki/scene-graph/nodes
---

There are three main implemenations of nodes in the scene graph that LittleKt offers. Those three are the base [Node](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/Node.kt), a 2D based node [Node2D](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/node2d/Node2D.kt), and the user interface module of nodes. We will be reviewing `Node` and `Node2D` here. Check out [The User Interface](/wiki/ui/the-user-interface) if you want to learn more on the UI.

## Node

The `Node` contains the base implementation that is used by all nodes in a scene graph. This contains lifecycle methods, render methods, adding/removing children, and any hiearchy changes.

A `Node` can contain one or more [Singal](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/util/signals.kt) types which can be used to subscribe to certain events that the node can emit.

For example, the `Node` class contains the following signals:

-   `onReady`: is emitted when the `ready()` callback is invoked
-   `onRender`: is emitted when the `render()` callback is invoked
-   `onDebugRender`: is emitted when `onDebugRender()` callback is invoked
-   `onUpdate`: is emitted when `update()` callback is invoked

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

## Node2D

The `Node2D` class contains an implementation on transforming a node in 2D space. The includes position, rotation, and scale. We have access to the local and global versions of these components. Making a change to any of these properties will dirty the hiearchy and update it's children.

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

-   `posotion`: local position immutable vector
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
