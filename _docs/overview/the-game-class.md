---
title: The Game Class
permalink: /docs/overview/the-game-class
---

## Game class

LittleKt also has a `Game` class which is also a `ContextListener` but offers a few additional things such scene management and switching, and some handy delegates for handling assets. It is a lightweight but has very common use-case on what most LittleKt applications require. This is purely optional and does not have to be used.

```kotlin
class MyGame(context: Context) : Game<Scene>(context) {}
```

Doesn't look much different than a `ContextListener` but it does take a generic type parameter that extends the `Scene` class. This is so we can create our own scene base class and use those as the absolute base within the `Game` class vs just a `Scene` class. But for this example, we can just pass in the base `Scene` class.

### Scenes

A `Scene` is nothing more than an empty abstract class the contains a bunch of lifecycle methods. It does nothing on its own and needs to be managed, via the `Game` class or a custom implementation.

```kotlin
abstract class Scene(val context: Context) : Disposable {
    /**
     * Invoked when a [Scene] is first shown.
     */
    open suspend fun Context.show() = Unit

    /**
     * Invoked on every render frame.
     */
    open suspend fun Context.render(dt: Duration) = Unit

    /**
     * Invoked when a resize event occurs.
     */
    open suspend fun Context.resize(width: Int, height: Int) = Unit

    /**
     * Invoked when this scene is hidden from view.
     */
    open suspend fun Context.hide() = Unit

    final override fun dispose() {
        context.dispose()
    }

    /**
     * Dispose of any assets here.
     */
    open fun Context.dispose() = Unit
}
```

### Usage

In order to use a scene, we must first create and add the scene to the `Game` class. We can do that by simplying calling `addScene()` and passing in the instance of the `Scene`. We can add as many scenes here as we want. We must ensure we also call `setSceneCallbacks(context)` to register context callbacks so that our scene lifecycle methods are invoked.

```kotlin
class MyGameScene(context: Context, private val font: BitmapFont) : Scene(context) {

    private val batch = SpriteBatch(context)

    override suspend fun Context.render(dt: Duration) {
        batch.use {
            font.draw(it, "Hello World", 50f, 50f)
        }
    }

    override fun Context.dispose() {
        batch.dispose()
    }
}

class SampleGame(context: Context) : Game<Scene>(context) {

    override suspend fun Context.start() {
        // we must call this in order to subscribe to the
        // context callbacks such as onRender.
        setSceneCallbacks(this)

        val font = resourcesVfs["my_font.fnt"].readBitmapFont()

        // reigsters the MyGameScene class
        addScene(MyGameScene(this, font))

        // sets the current scene to the registered instance of MyGameScene
        setScene<MyGameScene>()
    }
}
```
