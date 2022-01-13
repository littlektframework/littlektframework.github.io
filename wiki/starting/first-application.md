---
title: First Application
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

## Game class

LittleKt also has a `Game` class which is also a `ContextListener` but offers a few additional things such as loading and preparing assets, scene management and switching, and some handy delegates for handling assets. It is a lightweight but has very common use-case on what most LittleKt applications require.

```kotlin
class MyGame(context: Context) : Game<Scene>(context) {}
```

Doesn't look much different than a `ContextListener` but it does take a generic type parameter that extends the `Scene` class. This is so we can create our own scene base class and use those as the absolute base within the `Game` class vs just a `Scene` class. But for this example, we can just pass in the base `Scene` class.

### Loading and preparing assets

To load and prepare assets we have some handy delegates that handle all of the hard work for us. This also prevents us from having to use `var` as a null or `lateinit var`. **Note:** We can not access any of these variables in the class's `init` method or else we will get an exception for accessing too early. The `Game` class provides a `create` class which can be used similarly.

Loading an asset we can use the `load` method with returns a `GameAsset` object which can be used as a delegate to access that actual asset we need, which in this case is the `Texture`.

```kotlin
val texture by load<Texture>(resourcesVfs["texture.png"])
```

This loads a `Texture` via a delegate and assigns it to the `texture` variable. Great! Now if you are thinking how can use a top level variable that requires this texture to be loaded and prepared, such needing a slice from it. Well not to fret, we also have a delegate for that too!

If we need a top level variable, and need to avoid `null` and `lateinit var` we can use the `prepare` method.

```kotlin
val texture by load<Texture>(resourcesVfs["texture.png"])
val slices by prepare<TextureSlice> { texture.slice(16, 16) }
```

The `prepare` method is essentially the same as the Kotlin's `lazy` delegate but does one thing more within the `Game` class. Once all the assets are loaded, any variable that needs prepared via the `prepare` will be invoked and created. Once that happens, the `Game` class will invoke the `create` method. All variables will be accessible by the time the `create` method is invoked. If for some reason your game doesn't need it prepared by the time `create` is invoked, then we can just use `lazy` instead and access whenever it is truly needed.

```kotlin
class MyGame(context: Context) : Game<Scene>(context) {

    val texture by load<Texture>(resourcesVfs["texture.png"]) // loads on a separate thread
    val slices by prepare<TextureSlice> { texture.slice(16, 16) }

    override suspend fun Context.run() {
        // access any of the variables from above
        // the Game class prevent override of the start method but provides the 'rum' method instead.
        // do any of the rendering and update logic here
    }
}
```

Now if we run the application, we should see a window pop up with the title of _"My First LittleKt App"_.

Next step: [creating your first game](/wiki/starting/first-game).
