---
title: Audio Streaming
permalink: /docs/0.13.0/audio/audio-streaming
---

LittleKt supports two ways of playing audio. The first way is loading an [AudioClip](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/audio/AudioClip.kt) into memory and playing it. The other is using an [AudioStream](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/audio/AudioStream.kt) to stream and play an audio file.

## AudioStream

An `AudioStream` is meant for playing longer audio files such as music. This allows the audio to be streamed and played instantly versus having to try to decode the entire audio and load it into memory all in one go.

Load and play an audio stream:

```kotlin
val stream: AudioStream = resourcesVfs["music.mp3"].readAudioStream()
stream.play(volume = 1f, loop = false)
```

Setting the `volume` or `loop` parameter on the `play` method will set the stream to the current volume and loop. We can also play a stream just by calling `play()` with out and parameters and it will default to the current volume and looping state.

We can adjust the volume and looping as well:

```kotlin
val stream: AudioStream = resourcesVfs["music.mp3"].readAudioStream()
stream.volume = 0.5f // must be between 0 and 1. 1 being the max
stream.looping = true
```

Pausing/resuming and stopping a stream:

```kotlin
val stream: AudioStream = resourcesVfs["music.mp3"].readAudioStream()
stream.pause()
stream.resume() // resumes from last position
stream.stop() // resets to beginning of the stream
```

## PCM Output

A `PcmOutput` plays raw samples written by our own callback, such as a custom mixer or a synth. The callback fills `buffer` with `frames` frames of interleaved samples from `-1` to `1`. On desktop it runs on the audio thread, so guard any state shared with the game loop.

```kotlin
var phase = 0.0
val step = 2.0 * PI * 220.0 / 44100 // a 220 Hz tone
val output = audio.createPcmOutput(sampleRate = 44100, channels = 2, bufferFrames = 1024, bufferCount = 4) { buffer, frames ->
    for (f in 0 until frames) {
        val sample = sin(phase).toFloat() * 0.2f
        buffer[f * 2] = sample
        buffer[f * 2 + 1] = sample
        phase += step
    }
}
output.play() // starts paused
output.volume = 0.5f
println(output.latency) // bufferFrames * bufferCount / sampleRate
output.pause()
output.stop() // drops the queued buffers
output.release()
```

## Audio Samples

`readAudioSamples` decodes a WAV, OGG, or MP3 file into `AudioSamples`: interleaved float samples to mix through a `PcmOutput`.

```kotlin
val wave: AudioSamples = resourcesVfs["hit.ogg"].readAudioSamples()
val fromBytes: AudioSamples = bytes.decodeAudioSamples()
val fromWav: AudioSamples = decodeWav(bytes)

val first = wave.samples[0] // interleaved, wave.channels per frame
val seconds = wave.frames / wave.sampleRate.toFloat()
```

WAV `smpl` loop points and `cue ` markers are kept. `loopStart` and `loopEnd` are `-1` if there is no loop.

```kotlin
val loopStart = wave.loopStart // first frame of the loop
val loopEnd = wave.loopEnd // frame after the last frame of the loop
val markers: IntArray = wave.markers // sorted marker frames
```
