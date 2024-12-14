---
title: 2D Meshes
permalink: /docs/2d/meshes
---

A [Mesh](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/Mesh.kt) is a collection of vertices that are used to describe geometry in order to render. By default, a mesh makes use of vertex buffer objects (VBOs). An [IndexedMesh](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/IndexedMesh.kt) extends a `Mesh` and uses a collection of indices, in addition to vertices, to describe geometry. 

`IndexedMesh` is used in [SpriteBatch](/docs/2d/spritebatch) to store the geometry to upload all the vertex information in a single batch for rendering which allows for performance gains by reducing draw calls.

## Creating a Mesh

To create a `Mesh` we must describe the data in each vertex by defining a `VertexAttribute` by first creating the `MeshGeometry`.

```kotlin
val geometry = CommonMeshGeometry(
                    VertexBufferLayout(
                        listOf(
                            VertexAttribute(VertexFormat.FLOAT32x3, 0, 0, VertexAttrUsage.POSITION),
                            VertexAttribute(
                                VertexFormat.FLOAT32x2,
                                VertexFormat.FLOAT32x4.bytes.toLong() + VertexFormat.FLOAT32x3.bytes.toLong(),
                                2,
                                VertexAttrUsage.TEX_COORDS
                            )
                        ).calculateStride().toLong()
                    ),
                    size = 1000
                )
val vertices = floatArrayOf(
    -1f, -1f, 0f, 0f, 0f, // x1, y1, z1, u1, v1,
    1f, -1f, 0f, 1f, 0f, // x2, y2, z2, u2, v2
    1f, 1f, 0f, 1f, 1f, // x3, y3, z3, u3, v3
    -1f, 1f, 0f, 0f, 1f // x4, y4, z4, u4, v4
)
geometry.add(vertices)

val mesh = Mesh(device, geometry)
```

The mesh above was created using a `FloatArray` to describe the vertex data. The mesh is using a `POSITION`, which has a size of three floats, and a `TEX_COORDS` which has a size of two floats. Our total vertex size would then be 5. The first three points are the position coordinates and the next two would then be the texture coordinates. This is repeated for each vertex.

## Rendering

To render a mesh, we must pass the mesh geometry info into a `RenderPassEncoder`. But before we do any of that, we must first call `mesh.update()` in order to update the underlying mesh buffers (vertex and/or index buffers), if the underlying geometry has changed. This will recreate any buffers that have ran out of room and upload it to the GPU.

```kotlin
mesh.update() // update the mesh
renderPass.setIndexBuffer(mesh.ibo, IndexFormat.UINT16) // if we are using an IndexedMesh
renderPass.setVertexBuffer(0, mesh.vbo)

// set render pass pipeline & bind groups
renderPass.setPipeline(...)

// draw if using we set an index buffer
renderPass.drawIndexed(indexCount = 6, instanceCount = 1)

// otherwise, draw with vertex
renderPass.draw(vertexCount = 4, instanceCount = 1)
```

## Mesh Utilities

Creating and setting the vertex information manually is great when we need fine control on how the mesh works. Sometimes it is easier to just have something that does it automatically. LittleKt has a few helper extensions the allows builidng a `Mesh` fast and simple. As well as a DSL to help set common vertex data.

### Creation

For example, if we wanted a `Mesh` that contained position coordinates, a packer color, and texture coordinates, we could simply use the helper extension as so.

```kotlin
val mesh = textureMesh(device, size = 100) {
    // we have CommonMeshGeometry scoped in here, so we can manipulate as we need
    // e.g:
    addVertex { 
        position.x = 0f
        position.y = 0f
        texCoords.x = 0f
        texCoords.y = 0f
    }
}

// if in Context scope
val mesh = textureMesh(size = 100) {
    // we have CommonMeshGeometry scoped in here, so we can manipulate as we need
}
```

Built-in mesh creation methods:

-   `mesh()`: Requires passing in a list of `VertexAttribute`. This is the base method the other builder methods use to construct the mesh.
-   `colorMesh()`: A mesh with vertex info of `POSITION` and `COLOR`
-   `textureMesh()`: A mesh with vertex info of `POSITION`, `COLOR` and `TEX_COORDS`


Built-in indexed mesh creation methods:

-   `indexedMesh()`: Requires passing in a list of `VertexAttribute`. This is the base method the other builder methods use to construct the mesh.
-   `colorIndexedMesh()`: An indexed mesh with vertex info of `POSITION` and `COLOR`
-   `textureIndexedMesh()`: An indexed mesh with vertex info of `POSITION`, `COLOR` and `TEX_COORDS`

### Setting common patterns for Indices

When creating an indexed mesh, usually we either want to use a quad or a triangle. A mesh offers methods for constructing the indices automatically for these two types. Any other way would need to be manually set.

```kotlin
indexedMesh.indicesAsQuad() // sets the indices as a quad shape
indexedMesh.indicesAsTri() // sets the indices as a triangle shape
```

### Using MeshGeometry to build a Mesh

By default, a `Mesh` uses a class called `MeshGeometry` that helps with building the vertex and index data. This handles total vertex size count as well as setting the vertices automatically. All we have to worry about is creating the mesh and setting each vertex. To use the vertex builder DSL, all we have to do is invoke the `addVertex()` method and set the `VertexView` data properties inside the lambda.

```kotlin
val mesh = textureMesh {
    addVertex {
        position.x = 50f
        position.y = 50f
        color = Color.WHITE
        colorPacked.value = colorBits
        texCoords.u = 0f
        texCoords.v = 0f
    }

    addVertex {
        position.x = 66f
        position.y = 50f
        color = Color.WHITE
        texCoords.u = 1f
        texCoords.v = 0f
    }

    addVertex {
        position.x = 66f
        position.y = 66f
        color = Color.WHITE
        texCoords.u = 1f
        texCoords.v = 1f
    }

    addVertex {
        position.x = 50f
        position.y = 66f
        color = Color.WHITE
        texCoords.u = 0f
        texCoords.v = 1f
    }

    indicesAsQuad()
}
```