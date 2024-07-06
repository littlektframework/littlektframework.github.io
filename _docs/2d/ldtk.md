---
title: LDtk
permalink: /docs/2d/tilemaps/ldtk
---

LittleKt offers full [LDtk](https://ldtk.io) parsing, loading, and rendering.

# Loading

A LDtk map can be loaded using the `resourcesVfs` file by using the `readLDtkMapLoader()` extension. This returns an `LDtkMapLoader` which has also parsed the initial map file. We just need to go an extra step to load either the entire map or load a level. This is done in order to reuse tilesets and image backgrounds that may be reused across multiple LDtk levels.
We can also pass in our own `TextureAtlas` to do the same with all the textures preloaded using the name of the texture file.

```kotlin
val mapLoader = resourcesVfs["ldtk/sample.ldtk"].readLDtkMapLoader()
val ldtkWorld = mapLoader.loadMap(loadAllLevels = true) // loads all levels at once
val ldtkLevel = mapLoader.loadLevel(levelIdx = 0) // loads the first level
```

## Using a TextureAtlas

As mentioned above, we can pass in a `TextureAtlas` which the `LDtkMapLoader` will use, if available, to create the `LDtkTileSet` objects from.

Two things we must do for this to work correctly:

1. Load a `TextureAtlas` that contains all of the tileset images and image backgrounds used in LDtk. This can be created strategically so that all the images used for each level are on a single texture. We could also load each `Texture` individually and use a `MutableTextureAtlas` to combine them at runtime.
2. Ensure that the names of each invidiual texture that is packed into the atlas matches the filename with extension of the image being loaded. For example, if we have a tileset image in the directly `ldtk/my_tileset.png`. We would ensure that in the `TextureAtlas` it has the name of `my_tileset.png`. No directory path.

# Rendering

There are multiple ways to render the LDtk map.

1. Render the entire map at once
2. Render a specific level of the map
3. Render specific layers of a level of the map.

## Render the entire map at once

If the map needs to be rendered entirely at one time, the `LDtkWorld` class offers a render method that can do just that.

```kotlin
val batch = SpriteBatch(context)
val camera = OrthographicCamera(context.graphics.width, context.graphics.height)
batch.use(camere.viewProjection) {
    map.render(it, camera)
}
```

## Render a specific level of the map

If a specific level is needed, one can grab that by using the `levelsMap` property or the `get` operator on the `LDtkWorld` object.

```kotlin
val level = map["MyLevelName"]
```

To render it one can simply call the `render` method on the level object.

```kotlin
val batch = SpriteBatch(context)
val camera = OrthographicCamera(context.graphics.width, context.graphics.height)
batch.use(camere.viewProjection) {
    level.render(it, camera)
}
```

## Render specific layers of a level

One can access specific layers of a level by using the `layers` property or the `get` operator on the `LDtkLevel` object.

```kotlin
val layer = level["MyCustomTilesLayer"]
```

As with the LDtk world and level objects, rendering the layer is done the same:

```kotlin
val batch = SpriteBatch(context)
val camera = OrthographicCamera(context.graphics.width, context.graphics.height)
batch.use(camere.viewProjection) {
    layer.render(it, camera)
}
```

Rendering each layer separately can be advantageous due to being able to render other items of the application on top or below certain layers if needed.

```kotlin
val bgLayer = level["background"]
val foregroundLayer = level["foreground"]
batch.use(camere.viewProjection) {
    bgLayer.render(it, camera)
    player.render(it)
    foregroundLayer.render(it, camera)
}
```

## Entities

As we know, LDtk offers creating entities and setting certain field values on that entity in each level of the map. LittleKt offers a way to access those entities and thus their fields for each level.

One can do that by first grabbing the level from the `LDtkWorld` object and calling the `entities` method.

```kotlin
val mapLoader = resourcesVfs["ldtk/sample.ldtk"].readLDtkMapLoader()
val map = mapLoader.loadMap()
val level = map["MyLevelName"]

// returns a list
val enemies = level.entities("Enemy")

// returns a list - since we only have one hero entity on the map we can just grab the first value in the list
val hero = level.entities("Hero")[0]
```

### Fields

Now that we have our entities, we can now access their field values by using either the `field` or `fieldArray` methods on the `LDtkEntity` object.

#### Types

These methods expect a typed parameter to determine the value to return.
For example, if the `Hero` entity had an integer field named `health` defined, one would expect the `field` method to return an `Int`. It even supports fields that can be `null`.

```kotlin
// field() return an LDtkValueField object which wraps the actual value which can be accessed with the 'value' property
val health = hero.field<Int>("health").value
val canDie = hero.field<Boolean>("canDie").value

// can be null
val startingWep = hero.field<LDtkEnumValue?>.value
```

One can pass in any type passed on the LDtk field type that LDtk supports. The goes for `Int`, `Float`, `Boolean`, `Color`, `Point`, `LDtkEnumValue`, `LDtkTile`, and `LDtkEntityRef`.

#### Enums

One can also access Enums defined in LDtk:

```kotlin
// assuming we have an 'Items' enum defined in LDtk
val weapon = hero.field<LDtkEnumValue>("StartWeapon").value
if (weapon.name == "Sword") {
    // equip sword
}
```

#### Arrays

LDtk also offers defining the exact same fields above but as an array, or in the case of LittleKt, as a `List`. Accessing the array field is just as easy as the single value field but instead of a single value it returns a list of values.

```kotlin
// returns a list of points
val path = mob.fieldArray<Point>("walkPath").values
val backpack = hero.fieldArray<LDtkEnumValue>("backpack").values
```

# Disposing

## Disposing of a loaded LDtk World

To dispose of the textures that the LDtk world / levels own, we must called the `dispose()` method on the `LDtkMapLoader`. This is due to the `LDtkMapLoader` caching the textures when loading multiple LDtk levels. This will dispose any of the owned textures it loaded itself. If a `TextureAtlas` was passed in then the loader won't own any of the textures and therefor won't dispose of any.

```kotlin
mapLoader.release()
```
