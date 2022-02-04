---
title: Logging
permalink: /wiki/overview/logging
---

## Logger

**LittleKt** offers its own lightweight logging class that can print messages in as a formatted string called [Logger](https://github.com/littlektframework/littlekt/blob/master/core/src/commonMain/kotlin/com/lehaine/littlekt/log/Logger.kt).

We can create our own `Logger` instance either at app level and pass it down to the required classes or its own `Logger` instance in the specified class.

### Creating a Logger

Creating a `Logger` is very simple and straight forward. Generally, we can create the instance of the `Logger` in the `companion object` of a class to prevent multiple loggers from being created on each object.

```kotlin
class MyClass {

    companion object {
        private val logger = Logger<MyClass> // we use the classes 'simpleName' as the name by default
    }

    fun doSomething() {
        logger.info { "My info message" }
    }

}
```

### Using the Logger

`Logger` offers a few logging levels that can be used. Starting at the top, the least verbose to the most verbse:

-   `Fatal`: The least verbose. It can be logged to using `logger.fatal { "message" }`
-   `Error`: can be logged to using `logger.error { "message" }`
-   `Warn`: can be logged to using `logger.warn { "message" }`
-   `Info`: can be logged to using `logger.info { "message" }`
-   `Debug`: can be logged to using `logger.debug { "message" }`
-   `Trace`: The most verbove. It can be logged to using `logger.trace { "message" }`

#### Setting the Logging Level

By default the logging level is set to `Logger.Level.INFO`.

We can set the level of a specific `Logger` by doing the following:

```kotlin
val logger = Logger<MyClass>
logger.level = Logger.Level.DEBUG
```

If we want to set the level for all loggers that exist and those that will be created we can use the `setLevels` method:

```kotlin
// setLevels is used from the Logger companion object
Logger.setLevels(Logger.Level.DEBUG)
```
