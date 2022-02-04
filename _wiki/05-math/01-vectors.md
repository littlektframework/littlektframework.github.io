---
title: Vectors
permalink: /wiki/math/vectors
---

The [math](https://github.com/littlektframework/littlekt/tree/master/core/src/commonMain/kotlin/com/lehaine/littlekt/math) module offers a bunch of classes dealing with Vectors of different sizes. `Vec2`, `Vec3`, and `Vec4`. **It should be noted that the `Vec4` is not a `Quaternion` implementation!**

Each vector comes with a `Float` and `Int` types. They ended with `f` and `i` respectively. For each of these types, these vectors come with an **immutable** and **mutable** versions. By default, **LittleKt** will use immutable vectors.

**Immutable vectors:**

```kotlin
val vec2f = Vec2f(1f, 1f)
val vec3f = Vec3f(1f, 1f, 1f)
val vec3i = Vec3i(1, 1, 1)

// we can invoke certain math functions on these vectors but expect an 'out' parameter to do so.
val otherVec3f = Vec3f(1f, 1f, 1f)
val result = MutableVec3f()
vec3f.add(otherVec3f, result)
```

We can easily convert an immutable vector to a mutable type:

```kotlin
val vec2f = Vec2f(1f, 1f)
val mutable: MutableVec2f = vec2f.toMutableVec()

// convert back to immutable
val immutable = mutable.toVec()
```

Vectors come with your standard vector math functions. Most of these come with `operator` functions as well:

-   `add`: add scalars or another vector directly
-   `subtract`: substract another vector
-   `mul`: multiply vectors
-   `dot`: the dot product between two vectors
-   `cross`: the cross product between two vectors
-   `norm`: normalizes a vector
-   `rotate`: rotate the vector along an axis
-   `length`: the length of a vector
-   `scale`: scale the vector

**Example:**

```kotlin
val v = MutableVec3f()
v.add(1f, 2f, 3f)
v += Vec2f(1f, 2f, 3f)
```
