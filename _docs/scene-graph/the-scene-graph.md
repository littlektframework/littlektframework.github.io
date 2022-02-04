---
title: The Scene Graph
permalink: /docs/scene-graph/the-scene-graph
---

The [SceneGraph](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/SceneGraph.kt) is an optional tool that can be used to build our games. It handles creation, updates, adding and removing nodes, and even has an optional UI portion. This can be very useful if we are familiar with how the tree structure works in game engines such as [Godot](https://godotengine.org/) or [Unity](https://unity.com/). This particular implementation is heavily influenced by the scene tree in Godot.

## Overview

The scene graph itself is quite simple. It contains a single root [Node](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graph/node/Node.kt) that it manages and invokes it's `update()` method. Whenever we add a new node to the tree, it will get added directly to this root `Node`. The root `Node` will then invoke the `update()` method unto it's children and so on and so forth.

The scene graph also contains a root `Viewport` and `Camera` which is then used subsequently by any of the nodes on the tree. When a `Node` is part of the `SceneGraph` the instance of the graph can be obtained by accessing the `node.scene` property.

## Scene graph

When a node is connected directly or indirectly to the root `Node`, it becomes part of the scene graph. The `Node` will have certain lifecycle callbacks invoked upon entering (and upon leaving).

Order of lifecycle methods of a `Node` when added to a `SceneGraph`:

-   `onAddedToScene()`: Called when this `Node` is added to a `SceneGraph` after all pending `Node` changes are committed.

*   `ready()`:Called when this `Node` and all of it's children are added to the scene and active
*   `onPostEnterScene()`: Called when this `Node` and all of it's children are added to the scene and have themselves called `onPostEnterScene()`

### Tree Order

Most `Node` operations are done in tree order, meaning parents and siblinings with a lower rank in the tree will get notified before the current node.

#### "Becoming active" when entering the `SceneGraph`:

1. A `SceneGraph` is created.
2. The root of the scene is created and initialized.
3. Every node of the newly added scene will recevie that `onAddedToScene()` callback in top-to-bottom order.
4. An second callback `ready()` is invoked when a node all of its children are inside the scene.
5. An extra callback `onPostEnterScene()` is also invoked once all of its children inside the scene and active, from bottom-to-top order.
