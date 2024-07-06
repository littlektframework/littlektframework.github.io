---
title: Texture Atlas
permalink: /docs/2d/texture-atlas
---

The **JSON Array** based atlases are supported by **LittleKt**. Whether it is published by [Code & Web's](https://www.codeandweb.com/texturepacker) texture packer or LittleKt's own [texture packer](/docs/tools/texture-packer) implementation, or whatever else that supports the format.

LittleKt can read and load multi-packed atlases just as easily as a single based atlas using a [TextureAtlas](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/TextureAtlas.kt).

## TextureAtlas

We can load a `TextureAtlas` from a `VfsFile`:

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
```

We can access specific a specfic [TextureAtlas.Entry](https://github.com/littlektframework/littlekt/blob/1c8a9456ae18736a70ae24f69fcf0c51013fe6f3/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/TextureAtlas.kt#L41) within the atlas by either using the `get operator` for an exact match or `getByPrefix` to grab the first entry that matches the specified prefix. This is great for grabbing the first frame of an animation. An `entry` contains references to the the `Texture` and `TextureSlice` which can be for rendering.

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val diamond: TextureAtlas.Entry = atlas["diamond"]
val hero: TextureAtlas.Entry = atlas.getByPrefix("heroRun")
```

**Using a TextureAtlas.Entry**

```kotlin
val hero: TextureAtlas.Entry = atlas.getByPrefix("heroRun")

batch.use(renderPass)
    it.draw(hero.slice, 5f, 5f)
}
```

#### Loading a multi-packed atlas

If we have an atlas that is split into multiple atlas files and images - we can load them the exact same way as we would an atlas with a single JSON and image file:

```kotlin
// assuming with have files: tiles.atlas-0.json, tiles.atlas-1.json, etc..
// we can load either one as long the other files are referenced in the file
val atlas: TextureAtlas = resourcesVfs["tiles.atlas-0.json"].readAtlas()
```

The atlas parser and loader will read the `related_multi_packs` field under the `meta` tag in the JSOn file and will parse and load them as well all in one go. The entries are then sorted by alpha-numeric filenames _(file1.png, file2.png, ... file9.png, file10.png)_ so animations can stay intact.

#### Create animations

We can create an animation directly from a `TextureAtlas` by using the prefix of the names of the sprites within the atlas. See the [Animations](/docs/2d/animations) for more info on using animations.

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.getAnimation("heroRun")
```
