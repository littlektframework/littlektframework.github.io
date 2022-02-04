---
title: First Application
permalink: /wiki/starting/first-application
---

This tutorial assumes the initial project setup has already been completed.

For this tutorial we will be using the `JVM` target for our testing. Ensure there is a `jvmMain` module already created.

# The application

The first thing when creating a new LittleKt application is to create a `LittleKtApp`. This app, once started, will create a context in which we can pass on in to our listeners to make use of. Each target may take slightly different parameters when creating a new `LittleKtApp` but fortunately there is a method that we can make use of to make it easy.

```kotlin
// Under jvmMain/kotlin/my/game

fun main(args: Array<String>) {
    val app = createLittleKtApp {
        width = 960
        height = 540
        vSync = true
        title = "My First LittleKt App"
    }
}
```

Pretty easy, right? We can start the app by using the `start` method which expects a lambda that returns a `ContextListener`. But before that we need to actually create a `ContextListener`.

`ContextListener` allows use to "listen" in on the `Context` and access all the goodies it offers. Creating a `ContextListener` is as easy as extending the class under `commonMain`.

```kotlin
class MyGame(context: Context) : ContextListener(context) {

    override suspend fun Context.start() {
        // this is where we can use the context to add render calls, dispose, calls, etc. All the logic should go here.
        val texture = resourceVfs["texture.png"].readTexture() // reads a texture on the main thread from the resources
        onRender { dt -> // this adds a render updater that is called on every frame
            // render logic can go here
        }
    }
}
```

Now we can go back and start the app by calling the `start` method. The lambda passes in a `Context` reference which we can use to pass into our `ContextListener`.

```kotlin
app.start { MyGame(it) }
```

Now if we run the application, we should see a window pop up with the title of _"My First LittleKt App"_.
