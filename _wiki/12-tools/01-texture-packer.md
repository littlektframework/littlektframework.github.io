---
title: Texture Packer
permalink: /wiki/tools/texture-packer
---

LittleKt comes with its own version of packing textures into an atlas. It even comes with a handy gradle plugin if needed. It is located in the `tools/` module and is only available on the **JVM** platform.

Simple usage by code:

```kotlin
fun main(args: Array<String>) {
    val packer = TexturePacker(TexturePackerConfig().apply {
        inputDir = "./art/export_tiles/raw"
        outputDir = "./art/output_atlas"
        outputName = "tile.atlas"
        // or set texture packer options

        packingOptions = PackingOptions().apply {
            outputPagesAsPowerOfTwo = false
            allowRotation = true
            // or set other packing options
        }
    })
    packer.process() // processes the image files
    packer.pack() // packs and exports them
}
```

## Gradle Plugin

Instead of needing to call it in in code or needing to build a custom gradle script, we can easily just add the texture packer plugin to our build script, set any configuration, and kick it off.

**build.gradle.kts**

```kotlin
// we need to add the gradle plugin to our class path first
buildscript {
    val littleKtVersion: String by project
    repositories {
        mavenCentral() // if we are targeting release
        maven(url = "https://s01.oss.sonatype.org/content/repositories/snapshots/") // if we are targgetting snapshots
    }
    dependencies {
        classpath("com.lehaine.littlekt.gradle:texturepacker:$littleKtVersion")
    }
}

plugins {
    ...
    id("com.lehaine.littlekt.gradle.texturepacker") version "0.0.1-SNAPSHOT"
}
```

Add the maven repository to the `plguinManagement` block.

**settings.gradle.kts**

```kotlin
pluginManagement {
    repositories {
        gradlePluginPortal() // needed for other kotlin plugins that may be in use
        mavenCentral() // if we are targeting release
        maven(url = "https://s01.oss.sonatype.org/content/repositories/snapshots/") // if we are targgetting snapshots
    }
}
...
```

That is the bare minimum. It will use the default configurations when packing. If we want to set our own we can adjust them under the `littleKt` block in the same file:

**build.gradle.kts**

```kotlin
littleKt {
    texturePacker {
        inputDir = "art/export_tiles/"
        outputDir = "src/commonMain/resources/"
        outputName = "tiles.atlas"

        packing {
            allowRotation = true
        }
    }
}
```
