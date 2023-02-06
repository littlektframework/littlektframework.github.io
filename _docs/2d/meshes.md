---
title: 2D Meshes
permalink: /docs/2d/meshes
---

A [Mesh](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Mesh.kt) is a collection of vertices and indices that are used to describe geometry in order to render. By default, a mesh makes use of vertex buffer objects (VBOs) and vertex array objects (VAOs) whereever available.

`Mesh` is used in [SpriteBatch](/docs/2d/spritebatch) in order to store the geomtery to upload all the vertex information in a single batch for rendering which allows for performance gains by reducing draw calls.

## Creating a Mesh

To create a `Mesh` we must describe the data in each vertex by defining a `VertexAttribute`.

```kotlin
val mesh = Mesh(context.gl, isStatic = true, maxVertices = 4, maxIndices = 0, useBatcher = false, attributes = listOf(VertexAttribute.POSITION_VEC3 VertexAttribute.TEX_COORDS(0)))

val vertices = floatArrayOf(
    -1f, -1f, 0f, 0f, 0f, // x1, y1, z1, u1, v1,
    1f, -1f, 0f, 1f, 0f, // x2, y2, z2, u2, v2
    1f, 1f, 0f, 1f, 1f, // x3, y3, z3, u3, v3
    -1f, 1f, 0f, 0f, 1f // x4, y4, z4, u4, v4
)
mesh.setVertices(vertices)
```

The mesh above was created using a `FloatArray` to describe the vertex data. The mesh is using a `POSTION_VEC3`, which has a size of three, and a `TEX_COORDS(0)` which has a size of two. Our total vertex size would then be 5. The first three points are the position coordinates and the next two would then be the texture coordinates. This is repeated for each vertex.

## Rendering

To render the mesh, all we have to do is call the `render` method after we setup our mesh and set our vertices. By default, a `Mesh` will call autobind itself when rendering. We can disable this by setting `autoBind = false` when constructing the mesh.

```kotlin
mesh.render(drawMode = DrawMode.TRIANGLES) // omitting a shader
```

Typically, we will want to pass in a [Shader](/docs/shading/shaders) to the `render()` method. By doing so, we will need to ensure we are passing in the correct data, binding any `Texture`, and set any model transformations before binding the shader and setting it's uniforms.

```kotlin
mesh.render(shader) // defaults to DrawMode.TRIANGLES
```

## Mesh Utilities

Creating and setting the vertex information manually is great when we need fine control on how the mesh works. Sometimes it is easier to just have something that does it automatically. LittleKt has a few helper extensions the allows builidng a `Mesh` fast and simple. As well as a DSL to help set common vertex data.

### Creation

For example, if we wanted a `Mesh` that contained position coordinates, a packer color, and texture coordinates, we could simply use the helper extension as so:

```kotlin
val mesh = textureMesh(context.gl) { // we have access to MeshProps here which is used to construct a Mesh
    maxVertices = 4
    maxIndicies = 6
}

// if in Context scope
val mesh = textureMesh {
    maxVertices = 4
    maxIndicies = 6
}
```

Built in mesh creation methods:

-   `mesh()`: Requires passing in a list of `VertexAttribute`. This is the base method the other builder methods use to construct the mesh.
-   `colorMesh()`: A mesh with vertex info of `POSITION_2D` and `COLOR_PACKED`
-   `colorMeshUnpacked()`: A mesh with vertex info of `POSITION_2D` and `COLOR_UNPACKED`
-   `textureMesh()`: A mesh with vertex info of `POSITION_2D`, `COLOR_PACKED` and `TEX_COORDS(0)`
-   `positionMesh()`: A mesh with vertex info of `POSITION_2D`.
-   `position3Mesh()`: A mesh with vertex info of `POSITION_VEC3`.
-   `position4Mesh()`: A mesh with vertex info of `POSITION_VEC4`.

### Setting common patterns for Indices

When creating a mesh, usually we either want to use a quad or a triangle. A mesh offers methods for constructing the indices automatically for these two types. Any other way would need to be manually set.

```kotlin
mesh.indicesAsQuad() // sets the indices as a quad shape
mesh.indicesAsTri() // sets the indices as a triangle shape
```

### Using MeshGeometry to build a Mesh

By default, a `Mesh` uses a class called `MeshGeometry` that helps with building the vertex and index data. This handles total vertex size count as well as setting the vertices automatically. All we have to worry about is creating the mesh and setting each vertex. To use the vertex builder DSL, all we have to do is invoke the `addVertex()` method and set the `VertexView` data properties inside the lambda.

```kotlin
val mesh = textureMesh {
    maxVertices = 4
}.apply {
    geometry.run {
        addVertex {
            position.x = 50f
            position.y = 50f
            colorPacked.value = colorBits
            texCoords.u = 0f
            texCoords.v = 0f
        }

        addVertex {
            position.x = 66f
            position.y = 50f
            colorPacked.value = colorBits
            texCoords.u = 1f
            texCoords.v = 0f
        }

        addVertex {
            position.x = 66f
            position.y = 66f
            colorPacked.value = colorBits
            texCoords.u = 1f
            texCoords.v = 1f
        }

        addVertex {
            position.x = 50f
            position.y = 66f
            colorPacked.value = colorBits
            texCoords.u = 0f
            texCoords.v = 1f
        }

        indicesAsQuad()
    }
}

texture.bind()
mesh.render(shader) // no need to set the vertices or the count as the mesh batcher handles it automatically!
```

We can also use `MeshGeometry` directly without creating `Mesh` instance to allow the building of mesh geometry without needing to bind to OpenGL with a `Mesh`. We then can pass in the `MeshGeometry` instance when building the mesh and it will use that data to render.

```kotlin
val geometry = MeshGeometry(Usage.STATIC_DRAW, VertexAttributes(listOf(VertexAttribute.POSITION_2D, VertexAttribute.COLOR_PACKED)))
val mesh = Mesh(context.gl, geometry)
```
