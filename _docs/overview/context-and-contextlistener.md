---
title: Context and ContextListener
permalink: /docs/overview/context-and-contextlistener
---

LittleKt makes use of everything stemming from the [Context](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/Context.kt). The `Context` contains everything we need to actually create a game. It contains the instances of the `Graphics`, `Input`, `GL`, `Stats`, `Vfs`, and others. From just the context we can access all of these instances.

The context itself is also a `CoroutineScope`. We can launch coroutines directly from the context which will run on the main thread. If we want to run something in a separate thread, then we can create our own CoroutineContext and launch a coroutine using it instead. The `Vfs` instance also a `CoroutineScope` which can be used to read and write files on separate threads.

To get access to a `Context` instance we can create a [ContextListener](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/ContextListener.kt) which requires `Context` when constructing. To see how we can do the check out the [creating your first application](/docs/starting/first-application) page.

## Context

As stated above, the context contains all the references to the actual "meat" of LittleKt. The `Context` itself is just an interface that is implemented for each target platform. Through the access we can poll for input, add input processors, access the virtual file system, load assets through resources, store data, and even determine what platform it is currently running on run.

The context also provides creating callbacks for certain events such as rendering, resizing, and disposing. We can add as many callbacks as we needed. They will be called in the order they were added.

```kotlin
override suspend fun Context.start() {
    onRender { dt ->
        // render logic
        gl.clear(ClearBufferMask.COLOR_BUFFER_BIT)
    }

    onPostRender { dt ->
        // the same as render but runs after any render callbacks
    }

    onResize { width, height ->
        // handle resize logic
    }

    onDispose {
        // dispose any assets here
    }
}
```

By design, LittleKt uses [dependency injection](https://en.wikipedia.org/docs/Dependency_injection) pattern for everything we can make use of. LittleKt avoids singletons and global states. If we want to access the context in a class then we would need to ensure we pass down the reference of the said context to the required class. This may seem awkward if you never have used it but this makes sure the follows the separation of concern, decoupling classes, code reuse, and readability. LittleKt does not make use of any dependency injection framework.

### GL

We can access the **OpenGL** context directly by using `Context.gl`. The [GL](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/GL.kt) interface contains all the OpenGL calls implementation for the target platform and can and should make use of it.

The _GL_ interface also contains all the constant flag values that we have at our disposable as well, as one would assume. We can access them statically with _GL_: `GL.COLOR_BUFFER_BIT`

On top of using the integer flags directly, we can also use the typed inline classes that LittleKt offers. This can help with preventing obscure bugs and using the wrong flags for a certain OpenGL call. We can view all of these value classes here under [enums.kt](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/gl/enums.kt).

For example:

```kotlin
// use the int flag directly
gl.drawArrays(GL.TRIANGLES, 0, count)

// or we can use the DrawMode value class to set it
gl.drawArrays(DrawMode.TRIANGLES, 0, count)
```

## Context Listener

When a context is built is expects a context listener in order to initialize and begin rendering. By creating a `ContextListener` and passing it into the `LittleKtApp` a new context will be intialized with the specified listener. This allows the listener to gain access to the context instance as well as the context managing the specified listener by calling its lifecycle methods.

### Lifecycle

A listener contains a single lifecycle method:
`start()`: **This is called when the context is created and ready to be used**
