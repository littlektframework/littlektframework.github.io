---
title: Geometry
permalink: /docs/0.12.0/math/geometry
---

## Points

Similarly to how vectors work, points follow the immutability concept. By default a [Point](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/geom/Point.kt) is immutable unless converted to a mutable version.

**Immutable point:**

```kotlin
val point = Point(1f, 5f)
```

**Mutable point:**

```kotlin
val point = MutablePoint(1f, 5f)
point.x = 3f
```

## Angles

Instead of having to remember when to convert to and from degrees and radians, we can use the [Angle](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/geom/Angle.kt) `value` class. The `Angle` class offers converting to and from degrees and radians, the `cos`, `sin`, and `tan` values very easily as well as other mathmatical functions to make dealing with angles and rotations very easily.

By default, wherever **LittleKt** expects some sort of rotation or angle, it will expect an `Angle` type.

### Creating Angles

We can directly set it to zero with the following:

```kotlin
val rotation = Angle.ZERO
```

or we can convert from either radians or degrees to an `Angle`:

```kotlin
val rotation: Angle = 90.degrees // converts from degrees to an Angle
val rotation2: Angle = (1.5708).radians // converts from radians to an Angle
```

If we want to convert from an `Angle` to either degrees or radians:

```kotlin
val rotation: Angle = 90.degrees
val rotation2: Angle = (1.5708).radians

val degrees: Float = rotation2.degrees // converts from an Angle to degrees
val radians: Float = rotation.radians // converts from an Angle to radians
```

## Bresenham

There are two implementations of a the [Bresenham's line algorithm](https://en.wikipedia.org/docs/Bresenham%27s_line_algorithm) that casts out rays with a custom collider method that can be passed in. This can be found in the [bresenham](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/bresenham.kt) class.

We can cast a ray from one point to another with our own `pass` logic. **Note**: This implementation will be able to pass through _diagonal_ points.

```kotlin
val pass = castRay(0, 0, 5, 5) {x, y ->
    return !hasCollision(x, y) // our own collision logic
}
if (pass) {
    // the ray passes from point a to point b successfully!
} else {
    // the ray failed to pass fully!
}
```

If we want to ensure that the ray cannot pass through _diagonal_ points we can use the `castThickRay` method instead:

```kotlin
val pass = castThickRay(0, 0, 5, 5) {x, y ->
    return !hasCollision(x, y) // our own collision logic
}
if (pass) {
    // the ray passes from point a to point b successfully!
} else {
    // the ray failed to pass fully!
}
```

## Ray Intersections

A [Ray](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/Ray.kt) has an `origin` and a normalized `direction`. Each `intersect` function returns the distance along the ray to the hit, or `Ray.NO_HIT` (`-1`) on a miss.

```kotlin
val ray = Ray()
ray.setFromLookAt(origin, target)

ray.intersectBox(box) // 0 if the origin is inside
ray.intersectSphere(center, radius = 2f)
ray.intersectPlane(Vec3f.Y_AXIS, 0f) // normal and plane constant
ray.intersectPlane(normal, pointOnPlane)
ray.intersectTriangle(a, b, c, cullBackFaces = true) // CCW is front facing
```

Use `pointAt` to get the hit point.

```kotlin
val distance = ray.intersectPlane(Vec3f.Y_AXIS, 0f)
if (distance >= 0f) ray.pointAt(distance, result)
```

To test local geometry, transform the ray by the inverse of a global transform. The direction isn't normalized, so distances match the original ray.

```kotlin
localRay.setTransformed(ray, inverseTransform)
```

See [Picking](/docs/0.12.0/3d/picking) for casting rays from the camera.

## Spatial Hash

A [SpatialHash](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/spatial/SpatialHash.kt) is a uniform grid that finds items near a point, inside an area, or along a ray without checking every item. It works in 2D and 3D.

```kotlin
val hash = SpatialHash<Enemy>(cellSize = 4f)

hash.put(enemy, bounds) // a BoundingBox
hash.putPoint(bullet, x, y, z)
hash.putRect(enemy, x, y, width, height) // 2D, at z = 0

hash.remove(enemy)
enemy in hash
hash.clear()
```

`put` adds an item or moves it if it is already stored, so call it each time an item moves. Items are compared by equality, so their `equals` and `hashCode` must not change while stored.

### Queries

Queries fill a list passed in and don't allocate. Clear it before reuse.

```kotlin
val result = mutableListOf<Enemy>()

hash.query(box, result)
hash.queryRect(x, y, width, height, result) // 2D
hash.queryRadius(x, y, z, radius, result)
hash.queryCircle(x, y, radius, result) // 2D
hash.queryRay(ray, 50f, result) // within 50 units, unordered
```

`raycast` returns the nearest item along a ray, or `null`. The distance is stored in `lastHitDistance`. Pass a `RayTest` to return an exact distance per item, or `Ray.NO_HIT` to skip it.

```kotlin
val sphereTest = SpatialHash.RayTest<Enemy> { enemy, ray, _ ->
    ray.intersectSphere(enemy.position, enemy.radius)
}
val hit = hash.raycast(ray, maxDistance = 100f, test = sphereTest)
```

### Cell Size

Pick a cell size around the size of the most common item or query. Items much larger than a cell are stored in many cells, and queries much larger than a cell visit many.

For a 3D game on the ground, a large `cellSizeY` keeps every item in one layer.

```kotlin
val hash = SpatialHash<Enemy>(cellSize = 4f, cellSizeY = 100f)
```
