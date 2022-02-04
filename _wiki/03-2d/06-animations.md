---
title: Animations
permalink: /wiki/2d/animations
---

## Animation

The [Animation](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Animation.kt) class contains the info on the key frames of the what is to be animated. All this class holds are the list of key frames, the list of indices associated to each key frame in the order to be palyed back in, as well as a list of `Duration` frame times for the amount of time spent displaying each frame.

The `Animation<T>` class also expects a type parameter. This would usually be a [TextureSlice](/wiki/2d/textures-and-textureslices) but we can pass in any type we want to animate. For the following examples, we will be using a `TextureSlice`.

The `Animation` class itself doesn't handle any of the playback or playback times. We have to pass in the time expired to the class for it to determine which key frame is to be played. We can use an [AnimationPlayer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/AnimationPlayer.kt) to enable playback of an animation but it is not required.

And of course we can create our own instance of an animation by simply just passing in the list of frames, indices, and times without needing an atlas.

### Creating an animation from a TextureAtlas

We can easily create an animation from a `TextureAtlas` by doing the following below. See [Texture Atlas](/wiki/2d/texture-atlas) on more info on how to use a `TextureAtlas`.

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.getAnimation("heroRun")
```

We can also create our own animation based off the frames from an animation, we can do the following:

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.createAnimation("heroRun") {
    frames(indices = 0..2, frameTime = 150.milliseconds)
    frames(index = 3, frameTime = 300.milliseconds)
    frames(indices = 0..2, frameTime = 150.milliseconds)
    frames(indices = 4..5) // defaults to 100.millseconds
}
```

This creates an animation with frames of differing display times in the order of `[0, 1, 2, 3, 0, 1, 2, 4, 5]` instead of the default order of `1-5` at `100.millseconds`.

## Playback

What good is an animation if we can't play it back? Fortunately, we can use the `AnimationPlayer` for that.

Creating an `AnimationPlayer` expects a type parameter as well. This needs to match the type parameter of the `Animation` that needs played back.

### Using an AnimationPlayer

**Playing an animation in a loop:**

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.getAnimation("heroRun")

val anim = AnimaationPlayer<TextureSlice>()
anim.playLooped(heroRun)

onRender { dt ->
    anim.update(dt) // handles requesting the next frames in the current animation
}
```

**Playing an animation a specific amount of times:**

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.getAnimation("heroRun")
val heroIdle: Animation<TextureSlice> = atlas.getAnimation("heroIdle")

val anim = AnimaationPlayer<TextureSlice>()
anim.playOnce(heroIdle) // stops after one play through
anim.play(heroIdle, times = 5) // stops after 5 play throughs

onRender { dt ->
    anim.update(dt)
}
```

**Performing an action on a specific frame of an animation:**

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.getAnimation("heroRun")

val anim = AnimaationPlayer<TextureSlice>().apply {
    onFrameChange = { index ->
        if(index == 2) {
            // do something
        }
    }
}
```

**Stopping an animiation:**

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
val heroRun: Animation<TextureSlice> = atlas.getAnimation("heroRun")

val anim = AnimaationPlayer<TextureSlice>()
anim.playLooped(heroRun)

// ...

anim.stop() // stops the current animation from playing
```
