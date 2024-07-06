---
title: WebGPU Profiling
permalink: /docs/debugging/webgpu-profiling
---

# App Stats

We can view app-related stats by accessing the `Context.stats` property. By default, this tracks the app run time, the last delta time, the total rendered frames, the current fps (averaged over the last 25 frames), and WebGPU-related stats referred to as engine stats.

## Engine Stats

Engine stats tracks WebGPU related stats. This is enabled by default. The list of stats tracked are as follows:

-   `bufferAllocations`: All the buffer allocations and their size.
-   `textureAllocations`: All the texture allocations and their size.
-   `totalBufferSize`: The total size of all buffers
-   `totalTextureSize`: The total size of all textures
-   `triangles`: the estimated amount of triangles currently rendered
-   `textureBindings`: the total textures bound
-   `drawCalls`: the total amount of draw related calls invoked

## Tracking Custom Engine Stats

We can track custom stats, such as the way SpriteBatch tracks quads, in our code.
```kotlin
EngineStats.extra("My Stat", 1) // increases the "My Stat" by 1.
```

## Outputting Stats to the Console

Fortunately, we don't have to worry about formatting all these stats to render to the console. By default, `AppStats.toString()` handles this formatting already. All we have to do is just add it to our logger message and it will output in a nicely formatted way. Any "extra" stats are also outputted.

```kotlin
onUpdate { dt ->
    if (input.isKeyJustPressed(Key.P)) {
        logger.info { stats }
    }
}
```

```
[12:18:49.778] - [Thread: 1] - [JVM - UI Test]:
***************** APP STATS *****************
FPS(last 25 frames): 182.8
Run time : 2s
Draw calls: 2
~Triangles: 270
Buffers: 6 with memory usage of 0.0M
Textures: 2 with memory usage of 5.0M
SpriteBatch Quads: 135 [Extra]
****************** END APP STATS *************
```
