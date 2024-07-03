---
title: OpenGL Profiling
permalink: /docs/debugging/opengl-profiling
---

# App Stats

We can view app-related stats by accessing the `Context.stats` property. By default, this tracks the app run time, the last delta time, the total rendered frames, the current fps (averaged over the last 25 frames), and OpenGL-related stats referred to as engine stats.

## Engine Stats

Engine stats tracks OpenGL related stats. This is enabled by default. The list of stats tracked are as follows:

-   `bufferAllocations`: All the buffer allocations and their size.
-   `totalBufferSize`: The total size of all buffers
-   `shaderSwitches`: The total times shaders have been switched in the last call
-   `vertices`: the total vertices being rendered
-   `textureBindings`: the total textures bound
-   `drawCalls`: the total amount of draw related calls invoked
-   `calls`: the total OpenGL related calls invoked

## Outputting Stats to the Console

Fortunately, we don't have to worry about formatting all these stats to render to the console. By default, `AppStats.toString()` handles this formatting already. All we have to do is just add it to our logger message and it will output in a nicely formatted way.

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
FPS (last 25 frames): 115.4
Run time: 2s
GL calls: 83
Draw calls: 3
Vertices: 186
Textures: 3
Shaders: 2
Buffers: 4 with memory usage of 1.6M

****************** END APP STATS *************

Process finished with exit code 0
```
