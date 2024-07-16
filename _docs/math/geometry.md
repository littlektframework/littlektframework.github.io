---
title: Geometry
permalink: /docs/math/geometry
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
