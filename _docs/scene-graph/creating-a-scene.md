---
title: Creating a Scene
permalink: /docs/scene-graph/creating-a-scene
---

Creating and using a [SceneGraph](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/SceneGraph.kt) can done in an idiomatic way without all the verbose code of constantly adding nodes to a parent. **LittleKt** offers a DSL to do this very easily and enjoyably.

## Create a SceneGraph

In the `SceneGraph` and each `Node` exists a DSL method that creates the node and adds it directly to the the parent `Node` or `SceneGraph`.

```kotlin
val scene = sceneGraph(context) {
    // we are in the SceneGraph context - we can add nodes here!
}.also {
    it.initialize() // we must call initialize before calling 'update()'
}
```

The `SceneGraph`, by default, will use a `ScreenViewport`. If we want to use a different viewport, we can pass that in through both the constructor or the DSL. We can also pass in our own instance of a `SpriteBatch` that will be used internally by the scene graph for doing any sort of rendering. This can be useful if we want to lower draw calls. Due note that if we do pass in our own instance, we still need to manage and dispose it ourselves. If none is passed in, then a new instance will be created and managed by the `SceneGraph` itself.

Before we can use the `SceneGraph`, we must first ensure we call the `initialize()` method. This will initialize the `root` Node and trigger the `root.onPostEnterScene()` lifecycle method. The reason we must explicilty intialize the graph is due to needing to pass in the instance of `SceneGraph` to the `root` in order to start the Node initializing and lifecycle callbacks on a non-final method. Because we can extend a `SceneGraph`, the Kotlin compiler warns us to not access non-final properties or methods in a partially constructed object.

The `SceneGraph` is also an [InputProcessor](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/input/InputProcessor.kt). This is used mainly for determining input on the user interface nodes. When the scene graph is first created, it will add itself to the contexts list of input processors. When the scene graph is disposed, it will remove itself from that list.

### Adding Nodes

Adding nodes to a scene graph is just as easy as creating the scene graph.

```kotlin
val scene = sceneGraph(context) {
    node { // Node context - we can set any variable from Node here
        // 1
        name = "I am a parent!"

        onReady += {
            println("$name is ready!")
        }

        node {
            // 2
            name = "I am a child!"

            onUpdate += { dt ->
                println("update $name")
            }
        }
    }

    node {
        // 3
        name = "I am a sibling!"
    }
}
```

The order of operations here when creating a new node is, from top-to-bottom order a node instance will be created, the builder action is invoked, and then it is added to the parent.

This allows for the children to be added to the parent Node from bottom-to-top order before they are added to the scene.

For example, the scene graph above would like this:

1. Node **1** is created: `Node()`.
2. The `action` callback inside Node **1** is then invoked. This will set the name of the node to "I am a parent!" and then it will create node **2**: `Node()`.
3. Node **2** `action` callback is then invoked and sets it's name to "I am a child!".
4. Node **2** will then add its self to the parent context, which would be Node **1**: `Node.addTo(node)`.
5. Node **1** will then add its self to the parent context, which would be the root Node: `Node.addTo(root)`.
6. Node **3** is created: `Node()`.
7. Node **3** `action` callback is then invoked and sets its name to "I am a sibling!".
8. Node **3** then adds itself to the parent context, which would be the root Node: `Node.addTo(root)`.

## Using a SceneGraph

Once a `SceneGraph` is created, we need to call the `update()` and `render()` methods in `Context.onRender` in order for the nodes to do any updates and rendering. We will also want to make sure is receives `resize` events as well.

```kotlin
onRender { dt ->
    scene.update(dt)
    scene.render() // this will call GL.viewport()

    // we will need to make if we do other rendering with another camera / viewport
    // that we call GL.viewport using viewport.apply(context)
    camera.viewport.apply(context)
    camera.update()
}

onResize { width, height ->
    camera.update(width, height, context)
    scene.resize(width, height)
}

onDispose {
    scene.dispose() // disposes managed SpriteBatch, if it exists, and removes itself as an input processor
}
```
