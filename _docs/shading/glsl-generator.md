---
title: GLSL Generator
permalink: /docs/shading/glsl-generator
---

A [GlslGenerator](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/shader/generator/GlslGenerator.kt) provides most syntax of what an OpenGL ES 2.0 shader would use. We can create functions, variables, if statements, and other built in functions directly. This page will be mostly examples for each of the major feature it offers. For more info on how to use this with shaders checkout the [Shaders](/docs/shading/shaders) page.

## Usage

### Defining a Variable

We define can define variables by using delegates for each type of parameter we want to create. As well as passing in the variable type it expects as a parameter of the delegate.

```kotlin
// vertex
private val u_mat by uniform(::Mat4)
private val a_vec4 by attribute(::Vec4)
private val a_vec2 by attribute(::Vec3)
private var v_vec2 by varying(::Vec2)

// fragment
private val u_texture by uniform(::Sampler2D)
```

### Setting Precision

We can pass in an additional parameter of `Precision` when defining variables via delegates.

```kotlin
private val v_color by varying(::Vec4, Precision.LOW)
```

### Creating local variables

We can define variables via delegates or _literally_. Depending on the variable type, we can either add `.lit` to the end of it, such as for a `Float`, or `Int`.

```kotlin
init {
    val result by vec2() // create new vec2 via delegate
    result.x = 1f.lit // set x with literal float
    result.y = 5f.lit // set y with literal float
    gl_Position = vec4Lit(result, 42f, 1f) // generates "vec4(result, 42f, 1f);" in GLSL code.
}
```

### Creating Functions

We can define and use functions pretty similarly to how we define variables, via delegates and literals. We can make use of the `Func` delegate which expects the function return type and the types of any parameters it expects to be used in the function.

```kotlin
val returnFloat by Func(::FloatFunc, ::GLFloat) {
    10f.lit + it // returns new float
}

init {
    returnFloat(5f.lit)
}
```

```kotlin
val almostEqual by Func(::BoolFunc, ::GLFloat, ::GLFloat) { a, b ->
        abs(a - b) lt 1e-5f
    }

init {
    almostEqual(0.01f.lit, 0.001f.lit)
}
```