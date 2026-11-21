---
title: Audio Clips
permalink: /docs/0.12.0/audio/audio-clips
---

LittleKt supports two ways of playing audio. The first way is loading an [AudioClip](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/audio/AudioClip.kt) into memory and playing it. The other is using an [AudioStream](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/audio/AudioStream.kt) to stream and play an audio file.

## AudioClip

An `AudioClip` is meant for playing audio files short in duration that can be quickly loaded into memory. These are usually a few seconds or shorter. We can trigger an `AudioClip` multiple times if needed to play the same audio very quickly.

Load and play an audio clip:

```kotlin
val clip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
clip.play(volume = 1f, loop = false)
```

Calling `play()` without parameters uses the clip's current `volume` and doesn't loop. `play` returns an id for that play, or `-1` if it couldn't play.

```kotlin
val clip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
clip.volume = 0.5f // must be between 0 and 1. 1 being the max
val id = clip.play(loop = true)
clip.setVolume(id, 0.25f)
if (clip.isPlaying(id)) clip.stop(id)
```

An id goes stale once its play ends or its source is reused. Calls with a stale id do nothing.

Pausing/resuming and stopping a clip:

```kotlin
val clip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
clip.pause()
clip.resume() // resumes from last position
clip.stop() // stops every play of the clip
```

## Spatial Audio

`playAt` plays a clip at a point in world space, heard from `audio.listener`. Sounds played with `play` aren't affected by the listener.

```kotlin
val clip = resourcesVfs["engine.wav"].readAudioClip()
val engine = clip.playAt(car.x, car.y, car.z, loop = true, attenuation = AudioAttenuation(refDistance = 2f))
onUpdate {
    audio.listener.set(camera)
    clip.setPosition(engine, car.x, car.y, car.z)
}
```

`listener.set(camera)` matches the camera's position and orientation. The listener can also be moved directly:

```kotlin
audio.listener.setPosition(player.position)
audio.listener.setOrientation(forward, up)
```

### Attenuation

`AudioAttenuation` controls how a sound gets quieter with distance:

- `refDistance` (default `1f`): full volume within this distance.
- `maxDistance` (default `100f`): silent at this distance. Only used by `LINEAR`.
- `rolloff` (default `1f`): how quickly the volume falls off. `0` never falls off.
- `distanceModel` (default `INVERSE`): `INVERSE`, `LINEAR`, or `EXPONENTIAL`.

```kotlin
clip.playAt(x, y, z, attenuation = AudioAttenuation(maxDistance = 20f, distanceModel = DistanceModel.LINEAR))
```

### Platform Notes

- **Desktop**: only mono clips are positioned. Stereo clips play without positioning and log a warning once.
- **Web**: any clip is positioned. Spatial sounds go through a shared Web Audio context created on the first `playAt`. Browsers need a user gesture before audio plays.

See the [SpatialAudioExample](https://github.com/littlektframework/littlekt/blob/master/examples/src/commonMain/kotlin/com/littlekt/examples/g3d/SpatialAudioExample.kt) (`-spatialAudio`) for a listener following the camera, an orbiting looped speaker, and one shot pings.

## Simultaneous Sounds

### Desktop

`maxAudioSources` (default `32`) is the most sounds that can play at once. Sources are created as needed. When all are in use, a new clip takes the place of the oldest playing clip. Streams keep their source until stopped and are never taken.

```kotlin
createLittleKtApp {
    maxAudioSources = 64
}
```

### Web

`maxAudioClipInstances` (default `8`) is how many times each clip can overlap itself. Once reached, the oldest play of that clip restarts.

```kotlin
createLittleKtApp {
    maxAudioClipInstances = 16
}
```

## Master Volume and Output Device

See [Audio Output](/docs/0.12.0/overview/window-and-display#audio-output) for `audio.masterVolume` and output device selection.
