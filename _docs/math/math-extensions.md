---
title: Math Extensions
permalink: /docs/math/math-extensions
---

On top of all the math implementations, **LittleKt** also has a bunch of helper and utility math extensions that will aim to make math just a bit easier. They are all contained in the [math.kt](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/math/math.kt) file. There are many extensions offered so it is best to check them out and try them ourselves.

Here are a few notable ones:

### Powers of two

```kotlin
println(100.nextPowerOfTwo) // 128
println(100.prevPowerOfTwo) // 64
println(128.isPowerOfTwo) // true
```

### Fuzzy equal and fuzzy zero

```kotlin
val result = isFuzzyEqual(0.003f, 0.00312f) // true

val a = 0.003f
val b = 0.00312f

if (a ife b) { // infix function for isFuzzyEqual
    // true!!
}

val c = 0.0000023f
if(c.isFuzzyZero()) {
    // true!!
}
```

### Interpolation

```kotlin
fun Float.interpolate(l: Float, r: Float): Float = (l + (r - l) * this)
fun Float.interpolate(l: Int, r: Int): Int = (l + (r - l) * this).toInt()
fun Float.interpolate(l: Long, r: Long): Long = (l + (r - l) * this).toLong()
fun Float.interpolate(l: Double, r: Double): Double = (l + (r - l) * this)

fun Double.interpolate(l: Float, r: Float): Float = (l + (r - l) * this).toFloat()
fun Double.interpolate(l: Double, r: Double): Double = (l + (r - l) * this)
fun Double.interpolate(l: Int, r: Int): Int = (l + (r - l) * this).toInt()
fun Double.interpolate(l: Long, r: Long): Long = (l + (r - l) * this).toLong()
```

### Distance

```kotlin
fun distSqr(ax: Double, ay: Double, bx: Double, by: Double) = (ax - bx) * (ax - bx) + (ay - by) * (ay - by)
fun distSqr(ax: Float, ay: Float, bx: Float, by: Float) = (ax - bx) * (ax - bx) + (ay - by) * (ay - by)
fun distSqr(ax: Int, ay: Int, bx: Int, by: Int) = distSqr(ax.toDouble(), ay.toDouble(), bx.toDouble(), by.toDouble())
fun dist(ax: Double, ay: Double, bx: Double, by: Double) = sqrt(distSqr(ax, ay, bx, by))
fun dist(ax: Float, ay: Float, bx: Float, by: Float) = sqrt(distSqr(ax, ay, bx, by))
fun dist(ax: Int, ay: Int, bx: Int, by: Int) = dist(ax.toDouble(), ay.toDouble(), bx.toDouble(), by.toDouble())

fun distRadians(a: Double, b: Double): Double = abs(subtractRadians(a, b))
fun distRadians(a: Int, b: Int): Double = distRadians(a.toDouble(), b.toDouble())
```
