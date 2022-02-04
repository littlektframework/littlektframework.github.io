---
title: Coroutines and Threads
permalink: /docs/threading/coroutines-and-threads
---

**LittleKt** supports the use of [coroutines](https://kotlinlang.org/docs/reference/coroutines.html) and asynchronous operations.

## Coroutines

The `Context` is the default scope that should be used instead of `GlobalScope` in a **LittleKt** application. We can also use the `KtScope` object which points to the same `CoroutineContext`. Sometimes it might be easier to switch using `KtScope` vs trying to a `Context` reference.

LittleKt provides two main implementations of coroutine dispatchers:

-   `RenderingThreadDispatcher`: executes tasks on the main rendering thread. Available via `Disptachers.KT`. This is the default dispatcher used by the `Context` / `KtScope` internally.
-   `AsyncThreadDispatcher`: wraps an `AsyncExecutor` to execute tasks.
    -   `newSingleThreadAsyncContext()`: factory method that creates an `AsyncExecutor` with a single thread.
    -   `newAsyncContext(numThreads)`: factory method that creates an `AsyncExecutor` with the specified amount of threads.
    -   `AsyncThreadDispatcher`: class that allows to wrap an existing `AsyncExecutor`. Ensure that the `threads` property is set to the correct number of threads.

LittleKt also provides a few utility methods:

-   `onRenderingThread`: suspends the coroutine to execute a task on the main rendering thread and return its result. Should be used if you dispatch a
    corutine with a non-rendering thread dispatcher and need to execute a task on the main rendering thread, such as preparing a `Texture`.
-   `isOnRenderingThread`: checks if the corutine is being executed on the main rendering thread.

### Usage

Start a coroutine on the main rendering thread:

```kotlin
suspend fun Context.doWork() {
    launch { // can also call context.launch directly.
        logger.info { "A coroutine from the render thread!" }
    }
}
```

```kotlin
suspend fun Context.doWork() {
    KtScope.launch { // the same thing as context.launch
        logger.info { "A coroutine from the render thread!" }
    }
}
```

Performing asynchronous work outside the rendering thread:

```kotlin
fun doAsyncWork() {
    val executor = newSingleThreadAsyncContext()
    KtScope.launch {
        logger.info { "On render thread" }
        withContext(executor) {
            logger.info { "On async thread" }
        }
        logger.info { "Back on render thread" }
    }
}
```

Switching threads:

```kotlin
private val job = Job()
private val scope = CoroutineScope(job)

fun switchThreads() {
    scope.launch {
        logger.info { "On scope context!" }
        withContext(Dispatchers.KT) {
            logger.info { "On render thread" }
        }
        logger.info { "Back on scope context!" }
        onRenderingThread {
            logger.info { "Back on render thread"}
        }
    }
}
```

We can even pass data to the rendering thread from another thread using `Context.postRunnable()`. This will run the runnable in the rendering thread on the next frame before `render()` is called:

```kotlin
fun postRunnableWork() {
    val executor = newSingleThreadAsyncContext()
    KtScope.launch(executor) {
        logger.info { "On async thread" }
        context.postRunnable {
            logger.info { "I will run on the render thread next frame!" }
        }
        logger.info { "Still on async thread" }
    }
}
```
