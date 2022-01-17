---
title: The Game Class
---

## Game class

LittleKt also has a `Game` class which is also a `ContextListener` but offers a few additional things such as loading and preparing assets, scene management and switching, and some handy delegates for handling assets. It is a lightweight but has very common use-case on what most LittleKt applications require.

```kotlin
class MyGame(context: Context) : Game<Scene>(context) {}
```

Doesn't look much different than a `ContextListener` but it does take a generic type parameter that extends the `Scene` class. This is so we can create our own scene base class and use those as the absolute base within the `Game` class vs just a `Scene` class. But for this example, we can just pass in the base `Scene` class.

### Scenes

TODO
