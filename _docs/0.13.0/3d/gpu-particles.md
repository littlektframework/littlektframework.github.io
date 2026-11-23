---
title: GPU Particles
permalink: /docs/0.13.0/3d/gpu-particles
---

Spawns, moves, and draws particles entirely on the GPU. A
[ParticleEffect](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/particle/ParticleEffect.kt)
describes how particles look and move. A
[ParticleEmitter](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/particle/ParticleEmitter.kt)
is a `Node3D` that spawns them, and a
[ParticleRenderer](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/graphics/particle/ParticleRenderer.kt)
simulates them with a compute pass and draws them.

Everything is in `com.littlekt.graphics.particle`, shared by [2D](#2d) and 3D. For the CPU 2D system, see [Particles](/docs/0.13.0/2d/particles).

```kotlin
import com.littlekt.graphics.particle.*
```

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

Update emitters, simulate before the render pass, then draw particles after opaque geometry. Particles test against depth but don't write it, except `OPAQUE` ones.

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

With `flat = true`, `Sphere` and `Circle` spawn on a disc on local XY.

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

- `ParticleBlend.ALPHA` standard transparency, the default. Overlaps can mix in any order unless [sorted](#sorting).
- `ParticleBlend.ADDITIVE` adds light. Good for fire, sparks, and magic.
- `ParticleBlend.OPAQUE` solid and writes depth, with texels under half alpha cut out. Good for [mesh particles](#mesh-particles).
- `ParticleBlend.DISTORT` bends what is behind them. Good for heat haze and shockwaves. See [Distortion](#distortion).

## Sorting

Set `sorted = true` to draw particles back to front, so overlapping `ALPHA` particles mix correctly. Live particles are sorted on the GPU each frame for the camera passed to `simulate`. Without a camera, nothing is sorted.

```kotlin
val smoke = ParticleEffect(blend = ParticleBlend.ALPHA, sorted = true)
particles.simulate(commandEncoder, emitters, camera)
```

Sorting adds compute dispatches. Use it for alpha effects that need it, like smoke, not additive ones.

## Sub-Emitters

A `SubEmitter` spawns particles from another emitter when particles of its parent die or are born, such as sparks where each firework fades out. Events and spawns stay on the GPU.

```kotlin
val sparks = ParticleEmitter(particles, ParticleEffect(rate = 0f, spread = 180.degrees, inheritVelocity = 0.3f))
rockets.subEmitter = SubEmitter(sparks, SubEmitterTrigger.DEATH, count = 200, maxEvents = 16)
val emitters = listOf(rockets, sparks)
```

- `trigger` is `DEATH` (the default) or `BIRTH`.
- `count` (`8` by default) child particles spawn per event, in world space at the event's position, with the child's effect. They keep `inheritVelocity` of the triggering particle's velocity.
- `maxEvents` (`256` by default) caps the events per simulation. Extras are dropped.

The child must use the same renderer. Simulate and draw it like any emitter, and usually set its `rate = 0f`.

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

## Flipbook

A `Flipbook` plays the texture as a grid of frames, left to right and top to bottom. With `fps = 0f`, the default, the frames play once over each particle's life.

```kotlin
val flames = ParticleEffect(texture = flameSheet, flipbook = Flipbook(columns = 4, rows = 4))
val smoke = ParticleEffect(texture = smokeSheet, flipbook = Flipbook(columns = 8, rows = 8, fps = 24f, loop = true, randomStart = true))
```

`frames` limits the frames used. `blend` fades between frames and is `true` by default.

## Mesh Particles

Set `mesh` to draw each particle as a lit 3D `ParticleMesh` instead of a quad. `size` is about its length.

```kotlin
val shard = ParticleMesh.shard(device)
val shards =
    ParticleEffect(
        rate = 0f,
        mesh = shard,
        alignment = ParticleAlignment.VELOCITY,
        blend = ParticleBlend.OPAQUE,
        shininess = 64f,
    )
```

- `ParticleMesh.shard(device)` a faceted crystal.
- `ParticleMesh.rock(device, roughness, seed)` a lumpy rock.
- `ParticleMesh.sphere(device)` a smooth ball, such as for drops.
- `ParticleMesh.box(device)` a cube.

`BILLBOARD` meshes tumble around a random axis, `VELOCITY` points them along their velocity, and `HORIZONTAL` keeps them upright. `emissive` (`0` to `1`) makes them glow no matter the light, and `shininess` sets the highlight size. Mesh particles can't use `DISTORT`.

They are shaded with the renderer's `light`.

```kotlin
particles.light.direction.set(-0.4f, -1f, -0.3f)
particles.light.color.set(1.2f, 1.15f, 1.1f, 1f)
particles.light.ambient.set(0.25f, 0.28f, 0.35f, 1f)
```

The effect doesn't own the mesh. Release it yourself.

## Distortion

`DISTORT` particles draw a distortion map into a [DistortionEffect](/docs/0.13.0/3d/post-processing#distortion) pass instead of the scene. Use its `ringTexture` or `hazeTexture`, or your own map: `rg` is the push direction (`0.5` is none) and `a` the strength.

```kotlin
val shockwave =
    ParticleEffect(
        rate = 0f,
        size = 6f..6f,
        sizes = listOf(0.1f, 1f),
        colors = listOf(Color.WHITE, Color(1f, 1f, 1f, 0f)),
        texture = distortion.ringTexture,
        blend = ParticleBlend.DISTORT,
    )
```

Render them in the distortion pass. Passing the depth texture hides them behind geometry without attaching it.

```kotlin
val warpPass = distortion.beginPass(commandEncoder, hdrTarget.width, hdrTarget.height)
particles.render(warpPass, camera, warps, depthTarget)
warpPass.end()
```

`particles.distortionFormat` must match `distortion.format`. Both are `RGBA16_FLOAT` by default.

## Soft Particles

Set `softness` in world units to fade particles where they meet geometry. Pass the depth texture to `render` in a pass that attaches it read only.

```kotlin
val smoke = ParticleEffect(softness = 0.6f)
particles.render(pass, camera, emitters, depthTarget)
```

See [Decals & Depth](/docs/0.13.0/3d/decals#soft-particles) for the two pass setup.

## 2D

Use the same renderer and emitters with a `SpriteBatch` and a 2D camera. Set `depthFormat` to `null` and `flat = true` on each effect. Flat effects stay on the emitter's XY plane: directions, shapes, and gravity ignore `z`, and `Sphere` and `Circle` spawn on a disc. Without it, particles drift in `z` and get clipped by the orthographic camera.

```kotlin
val particles =
    ParticleRenderer(device).apply {
        colorFormat = graphics.preferredFormat
        depthFormat = null
    }
val fire =
    ParticleEmitter(
            particles,
            ParticleEffect(
                shape = EmitterShape.Box(Vec3f(30f, 4f, 0f)),
                speed = 80f..160f,
                size = 18f..30f,
                blend = ParticleBlend.ADDITIVE,
                flat = true,
            ),
        )
        .position(-250f, -150f)
val sparks =
    ParticleEmitter(
        particles,
        ParticleEffect(
            direction = Vec3f.X_AXIS,
            spread = 8.degrees,
            speed = 250f..400f,
            gravity = Vec3f(0f, -500f, 0f),
            alignment = ParticleAlignment.VELOCITY,
            blend = ParticleBlend.ADDITIVE,
            flat = true,
        ),
    )
val emitters = listOf(fire, sparks)
```

`position(x, y)` moves on `z = 0` and `rotation(angle)` rotates around z. Both return the emitter.

```kotlin
sparks.position(wheelX, wheelY).rotation(wheelAngle.radians)
```

Simulate before the pass. Particles draw immediately, so flush the batch before `render` when sprites drawn earlier should stay behind, and again before `end`.

```kotlin
onUpdate { dt ->
    emitters.forEach { it.update(dt) }

    renderFrame { frame, commandEncoder ->
        particles.simulate(commandEncoder, emitters)
        val pass = commandEncoder.beginRenderPass(RenderPassDescriptor(colorAttachment(frame, clearColor)))
        batch.begin(camera.viewProjection)
        particles.render(pass, camera, fire) // behind the wheel
        batch.draw(wheel, wheelX, wheelY)
        batch.flush(pass)
        particles.render(pass, camera, sparks) // in front of the wheel
        batch.flush(pass)
        batch.end()
        pass.end()
        pass.release()
    }
}
```

Units are pixels with the y-up 2D camera. `HORIZONTAL` alignment doesn't apply.

In a scene graph, use a [GpuParticles2D](/docs/0.13.0/scene-graph/nodes#gpuparticles2d) node instead. It takes the renderer, makes its effect flat, and draws in tree order.

See the [GpuParticles2DExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g2d/GpuParticles2DExample.kt) for a campfire, spinning sparks, a comet trail, and fireworks.

## Limits

- `ALPHA` particles aren't sorted unless `sorted = true`, so overlapping colors can mix in any order.
- `maxParticles` (`2048` by default) is a ring buffer. Once full, new particles replace the oldest.
- Call `simulate` once per frame per emitter. `render` can be called with several cameras, but sorting uses only the camera passed to `simulate`.
- Release emitters and the renderer when done.

```kotlin
onRelease {
    emitters.forEach { it.release() }
    particles.release()
}
```

See the [GpuParticlesExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/GpuParticlesExample.kt) for fire, sorted smoke, a fountain, fireworks with a sub-emitter, a ground glow and ring, a moving trail, and explosions. See the [VfxParticlesExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/VfxParticlesExample.kt) (`-vfxParticles`) for flipbook flames, mesh shards, rocks, and molten drops, and distortion shockwaves and heat haze.
