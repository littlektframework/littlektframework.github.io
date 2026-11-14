---
title: GPU Particles
permalink: /docs/0.12.0/3d/gpu-particles
---

Spawns, moves, and draws particles entirely on the GPU. A
[ParticleEffect](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/particle/ParticleEffect.kt)
describes how particles look and move. A
[ParticleEmitter](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/particle/ParticleEmitter.kt)
is a `Node3D` that spawns them, and a
[ParticleRenderer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/g3d/particle/ParticleRenderer.kt)
simulates them with a compute pass and draws them.

For the CPU 2D system, see [Particles](/docs/0.12.0/2d/particles).

## Renderer

Set the formats to match the render pass, like a `ModelBatch`. Set `depthFormat` to `null` if the pass has no depth target.

```kotlin
val depthTarget = renderTarget(TextureFormat.DEPTH24_PLUS_STENCIL8)
val particles =
    ParticleRenderer(device).apply {
        colorFormat = graphics.preferredFormat
        depthFormat = depthTarget.format
        sampleCount = 1 // or 4
    }
```

Drawing with more than `maxViewsPerFrame` cameras (`8` by default) in one frame needs a higher value.

## Effects and Emitters

A `ParticleEffect` is an immutable data class. Ranges pick a random value per particle. Sizes and speeds are in world units, times in seconds.

```kotlin
val sparks =
    ParticleEffect(
        rate = 200f,
        lifetime = 0.4f..0.9f,
        speed = 4f..8f,
        spread = 25.degrees,
        gravity = Vec3f(0f, -9.8f, 0f),
        colors = listOf(Color.YELLOW, Color(1f, 0.3f, 0f, 0f)),
        alignment = ParticleAlignment.VELOCITY,
        blend = ParticleBlend.ADDITIVE,
    )

val emitter = ParticleEmitter(particles, sparks).apply { position(0f, 1f, 0f) }
```

Spawns follow the emitter's global transform, so it can be added as a child of a model.

```kotlin
torch.addChild(ParticleEmitter(particles, fire).apply { position(0f, 0.5f, 0f) })
```

Use `copy` to tweak an effect. Assigning `emitter.effect` keeps live particles unless `maxParticles` changes, which clears them.

```kotlin
emitter.effect = sparks.copy(rate = 50f)
```

## Each Frame

Update emitters, simulate before the render pass, then draw particles after opaque geometry. Particles test against depth but don't write it.

```kotlin
val emitters = listOf(fire, smoke, sparks)

onUpdate { dt ->
    emitters.forEach { it.update(dt) }

    renderFrame { frame, commandEncoder ->
        particles.simulate(commandEncoder, emitters)
        val renderPass =
            commandEncoder.beginRenderPass(
                RenderPassDescriptor(
                    colorAttachment(frame, clearColor),
                    depthStencilAttachment = depthTarget.depthAttachment(),
                )
            )
        modelBatch.render(scene, environment)
        modelBatch.flush(renderPass, camera, dt)
        particles.render(renderPass, camera, emitters)
        renderPass.end()
        renderPass.release()
    }
}
```

`simulate` and `render` take a single emitter or a list. A list is simulated in one compute pass.

## Control

```kotlin
emitter.emitting = false // stop spawning at rate; live particles finish
emitter.timeScale = 0.5f // slow motion
emitter.burst(800) // spawn now, whether emitting or not
emitter.clear() // remove every particle

emitter.isActive // true while any particle may be alive
emitter.activeCount // slots simulated and drawn
```

For one shot effects, set `rate = 0f` and only `burst`.

```kotlin
val explosion =
    ParticleEffect(
        maxParticles = 4096,
        rate = 0f,
        lifetime = 0.6f..1.4f,
        shape = EmitterShape.Sphere(0.3f),
        spread = 180.degrees,
        radialSpeed = 4f..9f,
        drag = 1.5f,
        blend = ParticleBlend.ADDITIVE,
    )
```

## Shapes

Where particles spawn, in the emitter's local space.

- `EmitterShape.Point` at the emitter, the default.
- `EmitterShape.Sphere(radius, surface = false)` inside, or on the surface.
- `EmitterShape.Box(halfExtents)` inside a box.
- `EmitterShape.Circle(radius, edge = false)` on a flat circle on local XZ, or its edge.

Particles move within `spread` of `direction` (`180.degrees` is every direction) at `speed`. `radialSpeed` adds speed away from the center.

## Over Life

`sizes` and `colors` take up to 4 keys each, spread evenly from birth to death. `sizes` multiplies `size`. `colors` multiplies the texture.

```kotlin
val fire =
    ParticleEffect(
        rate = 220f,
        lifetime = 0.6f..1.1f,
        shape = EmitterShape.Circle(0.35f),
        spread = 12.degrees,
        speed = 1.2f..2.2f,
        size = 0.5f..0.8f,
        sizes = listOf(0.6f, 1f, 0.2f),
        colors =
            listOf(
                Color(1f, 0.9f, 0.4f, 1f),
                Color(1f, 0.45f, 0.1f, 0.8f),
                Color(0.6f, 0.1f, 0.05f, 0f),
            ),
        angularVelocity = -90f..90f,
        blend = ParticleBlend.ADDITIVE,
    )
```

## Alignment and Blending

`alignment` sets how particles face.

- `ParticleAlignment.BILLBOARD` faces the camera, the default.
- `ParticleAlignment.VELOCITY` faces the camera and stretches along velocity by `stretch` per unit of speed. Good for sparks and rain.
- `ParticleAlignment.HORIZONTAL` lies flat on world XZ. Good for ground rings and ripples.

`blend` sets how they mix with what is behind them.

- `ParticleBlend.ALPHA` standard transparency, the default.
- `ParticleBlend.ADDITIVE` adds light. Good for fire, sparks, and magic.

## World vs Local Space

By default particles stay in the world where they spawned, so moving emitters leave trails. Spawn positions are spread between the emitter's last and current position, so fast emitters don't leave gaps. `inheritVelocity` keeps a fraction of the emitter's movement.

`localSpace = true` keeps particles relative to the emitter so they move with it.

```kotlin
val trail = ParticleEffect(rate = 300f, spread = 180.degrees, speed = 0.1f..0.3f, inheritVelocity = 0.2f)
val aura = ParticleEffect(shape = EmitterShape.Sphere(1f, surface = true), localSpace = true)
```

## Texture

Particles use `particles.defaultTexture`, a soft round dot, unless `texture` is set.

```kotlin
val smokeTexture = resourcesVfs["smoke.png"].readTexture()
val smoke = ParticleEffect(texture = smokeTexture, drag = 0.3f)
```

The effect doesn't own the texture. Release it yourself.

## Limits

- `ALPHA` particles aren't sorted, so overlapping colors can mix in any order. Prefer `ADDITIVE` or soft, low alpha colors.
- `maxParticles` (`2048` by default) is a ring buffer. Once full, new particles replace the oldest.
- Call `simulate` once per frame per emitter. `render` can be called with several cameras.
- Release emitters and the renderer when done.

```kotlin
onRelease {
    emitters.forEach { it.release() }
    particles.release()
}
```

See the [GpuParticlesExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/GpuParticlesExample.kt) for fire, smoke, a fountain, a ground glow and ring, a moving trail, and explosions.
