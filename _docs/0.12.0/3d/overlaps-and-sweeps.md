---
title: Overlaps and Sweeps
permalink: /docs/0.12.0/3d/overlaps-and-sweeps
---

[Collision](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/spatial/Collision.kt) tests if shapes overlap and sweeps one shape along a motion to find where it first touches another. It supports spheres, capsules, axis-aligned boxes (`BoundingBox`), and triangles.

Nothing is allocated and it isn't thread safe. It is not a physics engine: there are no rigid bodies and no built-in character controller. Movement is up to the game; see [Sliding](#sliding) for a short loop.

## Capsules

A [Capsule](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/spatial/Capsule.kt) is every point within `radius` of the segment from `a` to `b`. It slides over edges smoothly, so it suits characters. Reuse one and move it.

```kotlin
val capsule = Capsule(a, b, radius = 0.5f)
capsule.setUpright(x, 0f, z, height = 2f, radius = 0.5f)

capsule.translate(delta)
capsule.translate(1f, 0f, 0f)
```

`setUpright` stands the capsule on a point along the y axis, with `height` including the rounded ends.

`bounds(result)` sets the box around the capsule and `sweepBounds(delta, result)` sets the box around its whole motion.

## Overlaps

Each `Collision.overlap*` function returns `true` if the shapes touch.

```kotlin
Collision.overlapSphereSphere(centerA, radiusA, centerB, radiusB)
Collision.overlapSphereBox(center, radius, box)
Collision.overlapSphereTriangle(center, radius, a, b, c)
Collision.overlapSphereCapsule(center, radius, capsule)
Collision.overlapCapsuleCapsule(capsuleA, capsuleB)
Collision.overlapCapsuleBox(capsule, box)
Collision.overlapCapsuleTriangle(capsule, a, b, c)
```

For two boxes use `BoundingBox.isIntersecting`.

## Sweeps

A sweep moves a shape by `delta` and finds where it first touches another. It returns `true` on a hit and fills in a `SweepHit`.

```kotlin
val capsule = Capsule().setUpright(x, 0f, z, height = 2f, radius = 0.5f)
val hit = SweepHit()

if (Collision.sweepCapsuleBox(capsule, delta, wallBox, hit)) {
    capsule.translate(delta.x * hit.time, delta.y * hit.time, delta.z * hit.time)
} else {
    capsule.translate(delta)
}
```

```kotlin
Collision.sweepSphereSphere(center, radius, delta, target, targetRadius, hit)
Collision.sweepSphereBox(center, radius, delta, box, hit)
Collision.sweepSphereTriangle(center, radius, delta, a, b, c, hit)
Collision.sweepSphereCapsule(center, radius, delta, capsule, hit)
Collision.sweepCapsuleSphere(capsule, delta, center, radius, hit)
Collision.sweepCapsuleCapsule(capsule, delta, target, hit)
Collision.sweepCapsuleBox(capsule, delta, box, hit)
Collision.sweepCapsuleTriangle(capsule, delta, a, b, c, hit)
Collision.sweepBoxBox(box, delta, target, hit)
```

Box vs triangle isn't supported. Triangles are solid on both sides.

### SweepHit

- `time`: how far along `delta` the shapes touch, from `0` to `1`. `0` means they already overlap at the start. Move by `delta * time` to stop at the contact.
- `point`: the contact point on the surface of the shape that was hit.
- `normal`: the surface normal at `point`, pointing toward the moving shape.

Reuse one `SweepHit` per query.

### Helpers

```kotlin
Collision.sweepBounds(center, radius, delta, result)
Collision.closestPointOnSegment(point, a, b, result)
Collision.closestPointOnTriangle(point, a, b, c, result)
Collision.segmentDistanceSqr(p1, q1, p2, q2)
```

`sweepBounds` sets the box around a moving sphere, for querying a [SpatialHash](/docs/0.12.0/math/geometry#spatial-hash).

## Nodes

`Node3D` can be tested directly. By default the world box around the node's bounds is tested. `precise = true` tests the triangles of each `MeshPrimitiveInstance` in the node and its children. Skinned meshes are tested in their bind pose.

```kotlin
if (pad.overlapsCapsule(capsule)) activate()

node.overlapsSphere(center, radius, precise = true)
node.sweepSphere(center, radius, delta, hit, precise = true)
node.sweepCapsule(capsule, delta, hit, precise = true)
```

Bounds are updated in `update(dt)`, so update nodes before testing them.

## Spatial Hash

`SpatialHash.sweepcast` passes every item whose bounds overlap the motion's box to a `SweepTest` and returns the first item touched, or `null`. The closest contact is stored in `hit`.

```kotlin
val bounds = BoundingBox()

val wall = hash.sweepcast(capsule.sweepBounds(delta, bounds), hit) { node, h ->
    node.sweepCapsule(capsule, delta, h, precise = true)
}
```

## Sliding

To slide along walls instead of stopping, sweep a few times. Stop just short of each hit, then remove the part of the remaining motion that goes into the wall.

```kotlin
val skin = 0.01f

for (step in 0 until 3) {
    val length = delta.length()
    if (length < 1e-5f) break
    val wall = hash.sweepcast(capsule.sweepBounds(delta, bounds), hit) { node, h ->
        node.sweepCapsule(capsule, delta, h, precise = true)
    }
    if (wall == null) {
        capsule.translate(delta)
        break
    }
    val travel = max(0f, hit.time - skin / length)
    capsule.translate(delta.x * travel, delta.y * travel, delta.z * travel)
    delta.scale(1f - travel)
    val into = delta.dot(hit.normal)
    delta.x -= hit.normal.x * into
    delta.y -= hit.normal.y * into
    delta.z -= hit.normal.z * into
}
```

See the [CollisionExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/CollisionExample.kt) for a capsule sliding through walls, a sphere projectile, and an overlap trigger.
