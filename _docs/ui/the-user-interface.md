---
title: The User Interface
permalink: /docs/ui/the-user-interface
---

## Overview

The user interface that LittleKt offers is very heavily inspired by [Godot](https://godotengine.org/). The aim was to have the strengths of Godot's UI implementation combined with the strengths of Kotlin. In other words, we want to be able to build a UI similar to Godots declaritively using a UI builder DSL in Kotlin.

The user interface is built on top of the `SceneGraph`. If you are unfamiliar with it or need more info, check out [The Scene Graph](/docs/scene-graph/the-scene-graph). The user interface also features a theming system, similarly to Godots, for the control nodes.
