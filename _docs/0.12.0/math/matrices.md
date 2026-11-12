---
title: Matrices
permalink: /docs/0.12.0/math/matrices
---

There are two implementations for matrices that are offered. A **3x3 column major** matrix [Mat3](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/Mat3.kt) and a **4x4 column major** matrix [Mat4](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/Mat4.kt).

Unlike vectors, these matrices are mutable by default and do not offer any immutable versions.

## Conventions

-   Matrices are **column-major** and use **column vectors**: `M * v`. Translation lives in the last column (`m03`, `m13`, `m23`).
-   Basis axes are the columns. `Mat4.set(xAxis, yAxis, zAxis, pos)` writes them as columns.
-   `setToWorld(position, forward, up)` builds a world transform whose `-Z` faces `forward`.
-   `scaleX`, `scaleY`, `scaleZ` and `getScale` (`Mat4` and `Mat3`) are column lengths, so they hold for `T * R * S` with non-uniform scale.
-   `Mat4.getRotation(MutableQuaternion)` ignores scale.

Euler angles use `YXZ` order everywhere: roll (Z) first, then pitch (X), then yaw (Y). Pitch is about X, yaw about Y, roll about Z. These all give the same rotation:

-   `Mat4.setFromEulerAngles(pitch, yaw, roll)`
-   `Mat4.rotate(eulerX, eulerY, eulerZ)`
-   `Mat3.setFromEulerAngles(eulerX, eulerY, eulerZ)` (degrees)
-   `MutableQuaternion.setEuler(pitch, yaw, roll)`
-   `Node3D.rotate(x, y, z)`

```kotlin
val a = Mat4().setFromEulerAngles(30.degrees, 45.degrees, 10.degrees)
val b = Mat4().setToRotation(MutableQuaternion().setEuler(30.degrees, 45.degrees, 10.degrees))
// a == b
```

## Functions

The matrices implementations offer the standard matrix functions one would expect:

-   `translate`: translates a matrix by its translation component
-   `rotate`: rotates a matrix by its rotation component
-   `mul`: post-multiplies a matrix with another matrix
-   `mulLeft`: pre-multiplies a matrix with another matrix
-   `setToIdentity`: sets the matrix to an identity matrix
-   `setToOrthographic`: sets the matrix to an orthographic projection
-   `setToPerspective`: sets the matrix to a perspective projection
-   `setToTranslate`: resets the matrix to an identity matrix and sets the translation component
-   `setToTranslateAndScaling`: resets the matrix to an identity matrix and sets the translation and scaling components
-   `setToRotation`: resets the matrix to an identity and sets the rotation component
-   `setToLookAt`: sets the matrix to look at the given position and target
-   `scale`: scales the matrix
-   `invert`: inverts the matrix
-   `toBuffer`: dumps the matrix data into a `FloatBuffer`
-   `toList`: dumps the matrix data into a `List<Float>`
