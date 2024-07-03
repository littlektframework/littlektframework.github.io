---
title: Shaders
permalink: /docs/shading/shaders
---

LittleKt offers utility classes for writing GLSL code, called shaders, in order to render items onto the screen. By default, the `SpriteBatch` class uses its own default shader to handle rendering. If we create our own `Mesh` class, we would have to pass in our own shader in our to see something on the screen.

## What are Shaders

Shaders are small programs written in GLSL, which is a C-like language, that is then loaded onto the GPU and processes data in order to render things onto the screen. For more info on what shaders are and how to actually use a shader check out the shader article on [LearnOpengl](https://learnopengl.com/Getting-started/Shaders).


## Creating Shaders

To use shaders in LittleKt, we have two classes available to us that we can extend, [FragmentShaderModel](https://github.com/littlektframework/littlekt/blob/72361217dbd8527cc8713d89d86837f0dc66c853/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/shader/Shader.kt#L23) and [VertexShaderModel](https://github.com/littlektframework/littlekt/blob/72361217dbd8527cc8713d89d86837f0dc66c853/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/shader/Shader.kt#L61). These classes, themselves, are a [GlslGenerator](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/shader/generator/GlslGenerator.kt) object. We can write the GLSL that targets OpenGL ES 2.0 and it will automatically handle any changes needed to make the shader work for WebGL and desktop. It will also handle updating the shader to the OpenGL 3.0 syntax if the system supports it.

### GLSL Generator

The [GLSL generator](/docs/shading/glsl-generator) is a way to write shaders in Kotlin which will then be converted in GLSL code at runtime. It is very simple to get started with. Do note that there may be some features or syntax missing. If you run into such an issue feel free to open an issue on the GitHub repo and we can see on how we can get it added in. With that said, it might not be worth writing shaders directly in Kotlin if you are fighting the framework. We can write pure GLSL code instead and it will still work.

#### A simple shader in Kotlin

We can define our variables for the shader at top level by using the delegate property. We then can pass in the variable type, such as **Mat4**, **Vec2**, **Vec3**, etc, that is going to be used. All of these variables can be **private** since they are of no use to anyone outside the shader. We will get into how to pass in data to a uniform later in just a bit. The names of the variable we use are the actual names that will be generated in GLSL code.

Once we have our variables defined, we can write the actual shader inside the `init { }` block of our class.

For a `VertxShader` we have access to the `gl_Position` variable that is inherited from `VertexShaderModel`. For a `FragmentShader` we have access to the `gl_FragColor` variable that is inherited from `FragmentShaderModel`.


```kotlin
class SimpleColorVertexShader : VertexShaderModel() {
    private val u_projTrans by uniform(::Mat4)
    private val a_position by attribute(::Vec4)
    private val a_color by attribute(::Vec4)
    private var v_color by varying(::Vec4)

    init {
        v_color = a_color
        gl_Position = u_projTrans * a_position
    }
}

class SimpleColorFragmentShader : FragmentShaderModel() {
    private val v_color by varying(::Vec4, Precision.LOW)

    init {
        gl_FragColor = v_color
    }
}
```

We also have the luxury of being able to dynamically generate shaders based on the parameters we pass into the constructor.

```kotlin
class MyVertexShader(color: Color) : VertexShaderModel() {
    private val u_projTrans by uniform(::Mat4)
    private val a_position by attribute(::Vec4)
    private var v_color by varying(::Vec4)

    init {
        if (color == Color.RED) { // this if statement will not be in the actual GLSL code
            v_color = vec4Lit(1f.lit, 0f.lit, 0f.lit, 1f.lit)
        } else {
            v_color = vec4Lit(1f.lit, 1f.lit, 1f.lit, 1f.lit)
        }
        gl_Position = u_projTrans * a_position
    }
}
```

### Shader parameters

By default, when creating a top level variable such a uniform, the GLSL generator will automatically generate a `ShaderParameter` for it and populate the `parameters` list. The parameters are added in the order they are defined in the shader. If we to expose one these parameters, we can by doing something like this:

```kotlin
class SimpleColorVertexShader : VertexShaderModel() {
    val uProjTrans get() = parameters[0] as ShaderParameter.UniformMat4 // we can now pass in a matrix!

    private val u_projTrans by uniform(::Mat4)
    private val a_position by attribute(::Vec4)
    private val a_color by attribute(::Vec4)
    private var v_color by varying(::Vec4)

    init {
        v_color = a_color
        gl_Position = u_projTrans * a_position
    }
}
```

We can access the shader parameters and update the values in the shader by using the variable directly.

```kotlin
val vert = SimpleColorVertexShader()
vert.uProjTrans.apply(myShaderProgram, myMatrix)
```

### Using Pure GLSL Code

If we did not want to use the Kotlin GLSL code generator, we still have the option of using GLSL code directly, with the goodies of defining the list of `ShaderParameter`. Most of the steps are the same, except instead of writing the code in the `init { }` block, we can override the `source` variable and write the GLSL code directly. We then have to create the `ShaderParameter` types ourselves and populate the `parameters` list. By doing so, we allow the shader models to still be validated and changed if needed by the `GlslGenerator` to support other platforms and OpenGL versions.

```kotlin
class SimpleColorVertexShader : VertexShaderModel() {
    val uProjTrans = ShaderParameter.UniformMat4("u_projTrans")
    val aPosition = ShaderParameter.Attribute("a_position")
    val aColor = ShaderParameter.Attribute("a_color")

    override val parameters: MutableList<ShaderParameter> =
        mutableListOf(
            uProjTrans, aPosition, aColor
        )

    // language=GLSL
    override var source: String = """
        uniform mat4 u_projTrans;
        
        attribute vec2 a_position;
        attribute vec4 a_color;
        
        varying vec4 v_color;

        void main() {
            v_color = a_color;
            gl_Position = u_projTrans * a_position;
        }
    """
}
```


## Creating a Shader Program

A [ShaderProgram](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/shader/ShaderProgram.kt) is made up of a `VertexShader` and `FragmentShader`. Using the simple shaders from the above section, we can create a new `ShaderProgram` by passing them into the constructor. We also have to ensure we `prepare` the program as well. Doing so will generate the GLSL code, if applicable, and compile the shaders.

```kotlin
val vert = SimpleColorVertexShader()
val frag = SimpleColorFragmentShader()
val shader = ShaderProgram<SimpleColorVertexShader, SimpleColorFragmentShader>(vert, frag).also { it.prepare(context) }

val batch = SpriteBatch(context)
batch.shader = shader

onUpdate {
    // use batch to draw with the new shader!
}
```