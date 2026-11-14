---
title: Picking
permalink: /docs/0.12.0/3d/picking
---

Finds what is under the cursor by casting a [Ray](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/Ray.kt) from the camera. Every test returns the distance along the ray, or `Ray.NO_HIT` (`-1`) on a miss.

## Pick Ray

`computePickRay` sets a ray from screen coordinates over the whole window. It returns `false` if the ray is not valid.

```kotlin
val ray = Ray()

onUpdate {
    camera.update()
    if (camera.computePickRay(this, ray, input.x.toFloat(), input.y.toFloat())) {
        // test the ray
    }
}
```

Pass a `Viewport` to pick within it instead.

```kotlin
camera.computePickRay(this, ray, input.x.toFloat(), input.y.toFloat(), viewport)
```

## Ground Clicks

Test against a plane and use `pointAt` to get the hit point.

```kotlin
val target = MutableVec3f()

if (input.isJustTouched(Pointer.POINTER1)) {
    val distance = ray.intersectPlane(Vec3f.Y_AXIS, 0f) // the y = 0 plane
    if (distance >= 0f) ray.pointAt(distance, target)
}
```

## Picking Nodes

`Node3D.intersectRay` tests a ray against a node and its children. For a few nodes, test each and keep the nearest.

```kotlin
var picked: Node3D? = null
var nearest = Float.MAX_VALUE
nodes.fastForEach { node ->
    val distance = node.intersectRay(ray)
    if (distance >= 0f && distance < nearest) {
        nearest = distance
        picked = node
    }
}
```

Bounds are updated in `update(dt)`, so update nodes before picking them.

### Bounds vs Precise

By default only the node's bounds are tested. They are tested in the node's own space, so rotated nodes stay tight.

`precise = true` tests the triangles of each `MeshPrimitiveInstance` in the node and its children. Skinned meshes are tested in their bind pose. It costs more, so use it on few nodes or after a bounds test passes.

```kotlin
node.intersectRay(ray, precise = true)
```

## Scaling Up

For many nodes, store them in a [SpatialHash](/docs/0.12.0/math/geometry#spatial-hash) and `raycast` it. Only nodes along the ray are tested, near to far, and it stops once nothing closer can be hit.

The framework doesn't own a broadphase. The game decides what goes in the hash and when it is updated. Use `globalBounds` to store a node by its world bounds.

```kotlin
class Pickable(val node: Node3D) {
    val bounds = BoundingBox()
}

val hash = SpatialHash<Pickable>(cellSize = 4f, cellSizeY = 100f)
val precise = SpatialHash.RayTest<Pickable> { unit, ray, _ -> unit.node.intersectRay(ray, precise = true) }

onUpdate { dt ->
    units.fastForEach { unit ->
        unit.node.update(dt)
        hash.put(unit, unit.node.globalBounds(unit.bounds)) // adds or moves
    }

    if (camera.computePickRay(this, ray, input.x.toFloat(), input.y.toFloat())) {
        val hovered = hash.raycast(ray, test = precise)
        val distance = hash.lastHitDistance
    }
}
```

Leave out `test` to use the stored bounds only.

See the [PickingExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/PickingExample.kt) for hover, click to move, and an area query over 1000 moving units.
