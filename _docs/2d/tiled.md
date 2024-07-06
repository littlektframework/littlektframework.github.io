---
title: Tiled
permalink: /docs/2d/tilemaps/tiled
---

LittleKt supports loading and rendering a [Tiled](https://www.mapeditor.org/) map. It currently only supports the `.tmj` / `.json` files. The XML `.tmx` is not supported.

# Loading

A Tiled map can be loaded using the `resourcesVfs` file by using the `readTiledMap()` extension. This returns an `TiledMap` which can be used to access the maps layers, objects, tilesets, and render it.
We can also pass in our own `TextureAtlas` to attempt to save on draw calls when the `TiledMap` is loaded.

```kotlin
val tiledMap: TiledMap = resourcesVfs["tiled/my-ortho-map.tmj"].readTiledMap()
```

## Using a TextureAtlas

As mentioned above, we can pass in a `TextureAtlas` which the internal `TiledMapLoader` will use, if available, to create the `TiledTileSet` objects from.

Two things we must do for this to work correctly:

1. Load a `TextureAtlas` that contains all of the tileset images and image backgrounds used in LDtk. This can be created strategically so that all the images used for each level are on a single texture. We could also load each `Texture` individually and use a `MutableTextureAtlas` to combine them at runtime.
2. Ensure that the names of each invidiual texture that is packed into the atlas matches the filename with extension of the image being loaded. For example, if we have a tileset image in the directly `tiled/my_tileset.png`. We would ensure that in the `TextureAtlas` it has the name of `my_tileset.png`. No directory path.

# Rendering

There are multiple ways to render the LDtk map.

1. Render the entire map at once
2. Render specific layers of a level of the map.

## Render the entire map at once

If the map needs to be rendered entirely at one time, the `TiledMap` class offers a render method that can do just that.

```kotlin
val batch = SpriteBatch(context)
val camera = OrthographicCamera(context.graphics.width, context.graphics.height)

batch.use(camere.viewProjection) {
    map.render(it, camera)
}
```

## Render specific layers of a map

One can access specific layers of a map by using the `layers` property or the `get` operator on the `LDtkLevel` object.

```kotlin
val layer = map["MyCustomTilesLayer"]
```

As with the LDtk map object, rendering the layer is done the same:

```kotlin
val batch = SpriteBatch(context)
val camera = OrthographicCamera(context.graphics.width, context.graphics.height)
batch.use(camere.viewProjection) {
    layer.render(it, camera)
}
```

Rendering each layer separately can be advantageous due to being able to render other items of the application on top or below certain layers if needed.

```kotlin
val bgLayer = map["background"]
val foregroundLayer = map["foreground"]
batch.use(camere.viewProjection) {
    bgLayer.render(it, camera)
    player.render(it)
    foregroundLayer.render(it, camera)
}
```

## Objects

Tiled offers creating _"object layers"_ which we can use create objects with certain shapes and properties. We can access these objects on these layers and use the properties to do whatever we need, such as instantiating our own _Entity_ class based off it as an example.

We can do that by first grabbing an objects layer from the `TiledMap`. We can do that by using either the `id` of the layer or the `name` of the layer. We then acess objects a similar way on the `TiledObjectLayer` by grabbing by `id` or `name`. We can also grab a list of `objects` by passing in a `type`.

```kotlin
val mobsLayer = it["mobs"] as TiledObjectLayer
val mobs: List<TiledMap.Object> = mobsLayer.objects
val boss: TiledMap.Object = mobsLayer["BigBoss"]
val health: Int = boss.properties["health"]?.int ?: 100

// our own game related logic using the object data
val bossInstance = BigBoss(boss.x, boss.y, health)
```

### Properties

We can also access objects property values by using the `properties` map on the object which returns a `Property` type. A `Property` contains a few fields for converting the value into the correct type so we can do it instantly without having to manually cast anything. Warning, it will through an a runtime exception if the value cannot be converted to the type, as it would normally. We can use the `int`, `float`, `bool`, and `string` properties to convert and return the value we want.

```kotlin
val boss: TiledMap.Object = mobsLayer["BigBoss"]
val healthProp: TiledMap.Property? = boss.properties["health"]
val health: Int = healthProp?.int ?: 100 // converts the prop to an Int
```

**Note**: for **file**, **color**, and **object** properties they will be returned as a `String` inside the `Property`.

# Disposing

## Disposing of a TiledMap

Once we are finished with the `TiledMap` we can call the `dispose()` method on the loaded map. This will dispose any of the textures it owns. If a `TextureAtlas` was passed in then the loader won't own any of the textures and therefor won't dispose of any.

```kotlin
tiledMap.release()
```
