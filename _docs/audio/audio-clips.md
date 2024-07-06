---
title: Audio Clips
permalink: /docs/audio/audio-clips
---

LittleKt supports two ways of playing audio. The first way is loading an [AudioClip](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/audio/AudioClip.kt) into memory and playing it. The other is using an [AudioStream](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/audio/AudioStream.kt) to stream and play an audio file.

## AudioClip

An `AudioClip` is meant for playing audio files short in duration that can be quickly loaded into memory. These are usually a few seconds or shorter. We can trigger an `AudioClip` multiple times if needed to play the same audio very quickly.

Load and play an audio clip:

```kotlin
val clip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
clip.play(volume = 1f, loop = false)
```

Setting the `volume` or `loop` parameter on the `play` method will set the clip to the current volume and loop. We can also play a clip just by calling `play()` with out and parameters and it will default to the current volume and looping state.

We can adjust the volume and looping as well:

```kotlin
val clip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
clip.volume = 0.5f // must be between 0 and 1. 1 being the max
clip.looping = true
```

Pausing/resuming and stopping a clip:

```kotlin
val clip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
clip.pause()
clip.resume() // resumes from last position
clip.stop() // resets to beginning of the clip
```
