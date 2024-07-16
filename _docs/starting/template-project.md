---
title: Template Project
permalink: /docs/starting/template-project
---

To get started on a clean slate, we can use the readily available [template starter project](https://github.com/littlektframework/littlekt-game-template). This is a base project that contains the bare necessities to get started with creating a game with LittleKt.

The template project is set up to use all the available platforms that LittleKt currently supports: **JVM** and **Web**.
If a certain platform isn't needed, simply deleting the source directory and the source sets in
the `build.gradle.kts` file will get rid of it.

## Usage

Clone the template repository, linked above, and open up in IntelliJ to get started. Each platform target contains a class to execute for their
respective platform.

### JVM

**Running:**

Run `LwjglApp` to execute on the desktop.

**Deploying:**

A custom deploy task is created specifically for JVM. Run the `package/packageFatJar` gradle task to create a fat
executable JAR. This task can be tinkered with in the `build.gradle.kts` file.

If and when the packages are renamed from `com.game.template.LwjglApp` to whatever, ensure to update the `jvm.mainClass`
property in the `gradle.properties` file to ensure that the `packageFatJar` task will work properly.

### JS

**Running:**

Run the `other/jsRun` gradle task like any other **Kotlin/JS** project to run in development mode.

**Deploying:**

Run the `kotlin browser/jsBrowserDistribution` gradle task to create a distribution build. This build will require a
webserver in order to run.
