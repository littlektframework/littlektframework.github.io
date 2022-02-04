---
title: Assets
permalink: /docs/io/assets
---

## Loading and preparing assets via AssetProvider

To load and prepare assets we have some handy delegates that `AssetProviders` provides that handles all of the hard work for us. This also prevents us from having to use `var` as a null or `lateinit var`. **Note:** We can not access any of these variables in the class's `init` method or else we will get an exception for accessing too early. The `Game` class provides a `create` class which can be used similarly.

We must first create a provider:

```kotlin
val provider = AssetProvider(context)
```

Loading an asset we can use the `load` method with returns a `GameAsset` object which can be used as a delegate to access that actual asset we need, which in this case is the `Texture`.

```kotlin
val texture by provider.load<Texture>(resourcesVfs["texture.png"])
```

This loads a `Texture` via a delegate and assigns it to the `texture` variable. Great! Now if you are thinking how can use a top level variable that requires this texture to be loaded and prepared, such needing a slice from it. Well not to fret, we also have a delegate for that too!

If we need a top level variable, and need to avoid `null` and `lateinit var` we can use the `prepare` method.

```kotlin
val texture by provider.load<Texture>(resourcesVfs["texture.png"])
val slices by provider.prepare<TextureSlice> { texture.slice(16, 16) }
```

The `prepare` method is essentially the same as the Kotlin's `lazy` delegate but will prepare each asset once all other assets have finished loading.

We can check if the `AssetProvider` has finished loading by using the `isFullyLoaded` property. We need to make sure we call `update()` in the render loop in order ensure the assets are finished loading and fully prepared.

```kotlin
class MyGame(context: Context) : ContextListener(context) {

    val provider = AssetProvider(context)
    val texture by provider.load<Texture>(resourcesVfs["texture.png"]) // loads on a separate thread
    val slices by provider.prepare<TextureSlice> { texture.slice(16, 16) }

    override suspend fun Context.start() {
        // access any of the variables from above
        // do any of the rendering and update logic here

        onRender {
            if(!provider.isFullyLoaded) {
                provider.update()
                return
            }
            // We are loading now! Do whatever logic we need to do here.
        }
    }
}
```
