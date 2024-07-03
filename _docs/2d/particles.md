---
title: Particles
permalink: /docs/2d/particles
---

LittleKt offers a more manual way of creating and simulating particles. It is a simple system but can be powerful if used cleverly. 

## Overview

A [Particle](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/Particle.kt) itself is just a class that holds the particle data such as position, scale, color, deltas, multipliers, and others. All of this data we can set manually and then is used within a [ParticleSimulator](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/graphics/ParticleSimulator.kt) to simulate it.


## Creating a Particle and ParticleSimulator

To create a `Particle` we can create it directly with it's constructor but it won't do us much good as the we would have to track each particle and dispose of it when we are done with it. Instead we can allocate a `Particle` from a `ParticleSimulator` using it's `alloc()` method.

### ParticleSimulator

A `ParticleSimulator` handles creation and disposing of a `Particle` via an internal pool so we don't have to. With that in mind, we can create `ParticleSimulator` by passing a value of the max number of particles that can be alive at one time.

```kotlin
val simulator = ParticleSimulator(2048)
```

### Particle

To create a `Particle` we can call the `alloc()` method from a `ParticleSimulator` and passing in a `TextureSlice` and a starting position.

```kotlin
val simulator = ParticleSimulator(2048)
val particle = simulator.alloc(slice, x, y)
```

At this point we can also set any other starting values and deltas that the particle is going to use.

```kotlin
val particle = simulator.alloc(slice, x, y).apply {
    scale((0.15f..0.25f).random())
    color.set(DUST_COLOR).also { p.colorBits = DUST_COLOR_BITS }
    xDelta = (0.25f..0.75f).random() * dir
    yDelta = -(0.05f..0.15f).random()
    life = (0.05f..0.15f).random().seconds
    scaleDelta = (0.005f..0.015f).random()
}
```

## Simulating and Rendering Particles

The `ParticleSimulator` comes with two methods we must call in order to update and draw the particeles. They are also called `update()` and `draw()`.

```kotlin
val simulator = ParticleSimulator(2048)
val batch = SpriteBatch(context)

onUpdate { dt ->
    simulator.update(dt)

    batch.use(camera.viewProjection) {
        simulator.draw(it)
    }
}
```


### Usage

Now this is where we need to be a bit clever and determine how positioning, scaling, and deltas to get the type of particle emission we are looking for.

For example, if we wanted dust to appear when a player runs on the ground in a platformer game, we could generate it similarly to this:

```kotlin
fun runDust(x: Float, y: Float, dir: Int) {
    create(5) { // creates 5 particles and sets a bunch of random deltas, life, and colors that move up and towards the direction we 
        val p = alloc(atlas.getByPrefix("fxSmallCircle").slice, x, y)
        p.scale((0.15f..0.25f).random())
        p.color.set(DUST_COLOR).also { p.colorBits = DUST_COLOR_BITS }
        p.xDelta = (0.25f..0.75f).random() * dir
        p.yDelta = -(0.05f..0.15f).random()
        p.life = (0.05f..0.15f).random().seconds
        p.scaleDelta = (0.005f..0.015f).random()
    }
}

private fun alloc(slice: TextureSlice, x: Float, y: Float) = particleSimulator.alloc(slice, x, y)

private fun create(num: Int, createParticle: (index: Int) -> Unit) {
    for (i in 0 until num) {
        createParticle(i)
    }
}
```

What happens here is when we invoke `runDust()` it will create 5 particles that will move slightly up and towards the specified direction at a given position for a very short amount of time while slightly increasing in scale.

```kotlin
runDust(player.x, player.y, -player.dir) // dir would be 1 or -1
```

We are not limited by creating a static amount of particles with the same texture. We can create a random amount that uses multiple texture slices that can all react differently. If we think about an explosion, it could look like creating  specific particles for the _white_ section of the explosion at the same time fade in the orange and red particles that expand outward.

### Reacting to the Environment

A `Particle` contains three lambda properties that we can make use of if we want some particles to react to the environment. For example, debris from a barrel bouncing off the ground.

`Particle` lifecycle callbacks:

* `onStart()`: invoked only once when a particle first comes alive.
* `onUpdate(Particle)`: invoked on every `update()` to the `ParticleSimulator`.
* `onKill()`: invoked when the particle is killed and disposed.

```kotlin
val particle = simulator.alloc(slice, x, y).apply {
    onUpdate = {
        if(hasCollision(it.x, it.y) && data0 == 0) {
            yDelta = -0.35f // bounce off the ground
            data0 = 1 // we only want it to bounce once so we can use the "data%d" properties to set it directly on this particle without having to track it
        } else if(hasCollision(it.x, it.y) && data0 == 1) {
            yDelta = 0f // stop it from moving completely
            xDelta = 0f
        }
    }
}
```
