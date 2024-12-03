---
title: Virtual File System
permalink: /docs/io/virtual-file-system
---

**LittleKt** comes with an abstraction over reading and writing to filesystems. The class that handles this is the [Vfs](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/file/Vfs.kt) class. This handles reading files into bytes. The [VfsFile](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/file/vfs/VfsFile.kt) class compliments the `Vfs` by allowing to create correct paths easily to files/assets and also able to read those files into certain formats / objects.

## Data buffers

By default, Kotlin multiplatform projects don't offer any data buffer type objects to allow reading and writing data. This makes it hard when needing to target multiple platforms. **LittleKt** offers implementation, with the API very similar to the `Buffer` types on the `JVM`, which makes it easy to use.

-   `ByteBuffer`: a buffer object for reading bytes. It is also possible to read bytes as an `Short`, `Int`, and `Float`.
-   `ShortBuffer`: a buffer object for reading and writing only shorts.
-   `IntBuffer`: a buffer object for reading and writing only integers.
-   `FloatBuffer`: a buffer object for reading and writing only floats.

## Key-Value Storage
A simple key-value storage `KeyvalueStorage` interface is available that stores simple key-value in plain text in the application working directly `./storage`. 

### Storing & loading Key-Values

### Store/Load ByteArray

```kotlin
val myData: ByteArray = "testValue".decodeToByteArray()
kv.store("myKey", myData)
// ...
val buffer:ByteBuffer? = kv.load("myKey")
```

### Store/Load String

```kotlin
val myData: String = "testValue"
kv.store("myKey", myData)
// ...
val loadData: String? = kv.load("myKey")
```

## Vfs

The `Vfs` offers a few methods for both reading files and key-value storage.

-   `readBytes()`: reads a file with the given paths and returns it as a `ByteBuffer`
-   `readStream()`: opens a stream to a file and which allows buffered reading of data from the stream

`Vfs` also supports coroutines for reading data. The `Vfs` itself is a `CoroutineScope` which can be used to launch coroutines when reading files.

```kotlin
fun loadData() {
    vfs.launch { // launches a coroutine within the vfs context
        val data = vfs.readBytes("my/path/to/file")
    }
}
```

## VfsFile

The thing that makes using a `Vfs` magical is using a `VfsFile`. The `VfsFile`, which contains a reference to a [PathInfo](), handles all the hard work on creating paths, normalizing the specified path, and much more. `PathInfo` offers a TON of utility extensions for transforming, creating, and reading paths. A `VfsFile` contains a reference to a `Vfs` that it belongs to.

### Creating paths and reading/writing

Creating a new `VfsFile` based off an existing `VfsFile`. Usually the `root` of a `Vfs`. This only creates a **path** to the file. It does not actually do any I/O on it.

```kotlin
val root: VfsFile = vfs.root // assuming we already have a root VfsFile created
val myFile: VfsFile = root["/path/to/file"]
```

#### Reading data from the `VfsFile`:

```kotlin
myFile.read() // reads as a ByteBuffer
myFile.readStream() // opens a stream for buffered reading
myFile.readBytes() // reads as a ByteArray
myFile.readString() // reads as a String
myFile.readLines() // reads as a list of strings
```

#### Reading data from a JSON string:

```kotlin
val myJsonFile: VfsFile = root["/path/to/json/file"]
myJsonFile.decodeFromString<MyJsonDataObject>()
```

#### Reading data from URL
We can also read data hosted elsewhere as long as the URL points to that data. We also have to make sure we use a specialized `Vfs` for
loading data over http: `Context.urlVfs`.

```kotlin
val myTexture: VfsFile = urlVfs["https://mysite.com/myimage.png"].readTexture()
```

#### Writing to key-value storage:

```kotlin
val data = "My data!!"
val file: VfsFile = root["/path/to/file"]
file.writeKeystore(data) // uses the paths basename as the key

val result: String = file.readKeystore() // uses the paths basename as the key
println(result)
```

### Usage with Vfs and Context

A `Vfs` instance contains a property called `root` which is a `VfsFile`. A `Vfs` requires a the path to the base directory when constructing. The root `VfsFile` is constructed based off that path.

A `Context` creates two `VfsFile` instances. One is a `resourcesVfs` which points to the projects **resources** directory. The second is the `applicationVfs` which points to the applications working directory. The third is a `urlVfs` which allows http requests with plain old URLs.

```kotlin
val context: Context
context.resourcesVfs["path/to/file/in/resources"].readBytes()
context.applicationVfs["path/to/file/in/app/dir"].readBytes()
context.urlVfs["https://mysite.com/myimage.png"].readTexture()
```

## Vfs loaders

**LittleKt** provides a bunch of extension utility methods to for reading `VfsFile` paths into different types of formats and objects. The are located in the [VfsLoaders](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/littlekt/file/vfs/VfsLoaders.kt) file.

#### Reading a texture

`readTexture()`: reads the and creates a `Texture` and `prepares` it. Accepts parameters for setting the `Texture.minFilter`, `Texture.magFilter`, and whether to use `mipmaps`.

```kotlin
val texture: Texture = resourcesVfs["my_texture.png"].readTexture()
```

#### Reading an image as Pixmap

`readPixmap()`: reads the file as a `Pixmap`. This does not create a `Texture`.

```kotlin
val pixmap: Pixmap = resourcesVfs["my_image.png"].readPixmap()
```

#### Reading a TextureAtlas

`readAtlas()`: reads a file as an atlas. Currently supports only JSON format.

```kotlin
val atlas: TextureAtlas = resourcesVfs["tiles.atlas.json"].readAtlas()
```

#### Reading a BitmapFont

`readBitmapFont()`: reads file as a `BitmapFont`. Aaccepts parameters for setting the `Texture.magFilter` and whether to use `mipmaps`.

```kotlin
val font: BitmapFont = resourcesVfs["arial_32.fnt"].readBitmapFont()
```

#### Reading a TTfFont

`readTtfFont()`: reads file as a `TtfFont`. Accepts a string for loading the specified glyphs in the string.

```kotlin
val font: TtfFont = resourcesVfs["arial.ttf"].readTtfFont() // defaults to base latin characters
```

#### Reading an LDtk Map

`readLDtkMapLoader()`: reads file as an `LDtkMapLoader`. Accepts parameters for an optional `TextureAtlas` and a `tilesetBorder` thickness when slicing any corresponding tile textures to prevent atlas bleeding. Loading a `LDtk` file will have the loaders created to read and parse the data to prevent loading and rebinding textures that are shared across levels.

```kotlin
val mapLoader = resourcesVfs["my_world.ldtk"].readLDtkMapLoader()
val world: LDtkWorld = mapLoader.loadMap()
```

If we aren't loading all the levels of a `LDtk` file at once, we can load other levels later with `loadLevel()`.

```kotlin
val mapLoader = resourcesVfs["my_world.ldtk"].readLDtkMapLoader()
val level: LDtkLevel = mapLoader.loadLevel(levelIdx = 1) // loads the 2nd level
```

#### Reading a Tiled Map

`readTiledMap()`: read the file as a `TiledMap`.

```kotlin
val tiledMap = resourcesVfs["my_tiled_map.tmj"].readTiledMap()
```

#### Reading an AudioClip

`readAudioClip()`: read the file as an `AudioClip`.

```kotlin
val audioClip: AudioClip = resourcesVfs["my_audio.wav"].readAudioClip()
```

#### Reading an AudioStream

`readAudioStream()`: read the file as an `AudioStream`.

```kotlin
val audioStream: AudioStream = resourcesVfs["my_music.mp3"].readAudioStream()
```
