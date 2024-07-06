---
title: Matrices
permalink: /docs/math/matrices
---

There are two implementations for matrices that are offered. A **3x3 column major** matrix [Mat3](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/Mat3.kt) and a **4x4 column major** matrix [Mat4](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/math/Mat4.kt).

Unlike vectors, these matrices are mutable by default and do not offer any immutable versions.

The matrices implementations offer the standard matrix functions one would expect:

-   `translate`: translates a matrix by its translation component
-   `rotate`: rotates am trix by its rotation component
-   `mul`: post-multiplies a matrix with another matrix
-   `mulLeft`: pre-muiltiplies a matrix with another matrix
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
