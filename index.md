---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: landing
article_header:
    actions:
        - text: Get Started
          type: outline-primary
          url: /docs/
        - text: GitHub
          type: outline-secondary
          url: https://github.com/littlektframework/littlekt
    height: 25vh
    theme: dark
    background_image:
        gradient: "linear-gradient(rgba(100, 63, 234, .2), rgba(242, 50, 97, .2))"
        src: /assets/images/index.png
title: LittleKt
excerpt: >
    A Kotlin Multiplatform 2D Game Framework that works on Desktop, Mobile, and Browser.
data:
    sections:
        - title: What is it?
          excerpt: >
              LittleKt (Little Kotlin) is a multiplatform 2D game framework written in Kotlin.  LittleKt provides a huge set of common tools and utilities to help create your   game while being low level enough to build your own engine or framework on top    of it.

              LittleKt is competely free and open-source under the Apache 2.0 license which means no fees or royalites. Everything written is completely yours.
        - title: Features
          children:
              - title: Multiplatform
                excerpt: Deploy your game on desktop, mobile, and web using the same code base.
              - title: Open Source
                excerpt: Licensed under a very the very permissive Apache 2.0 and open to contributions.
              - title: Lightweight
                excerpt: Extremely lightweight framework to allow building custom engines and frameworks ontop of.
              - title: Tools and Utilities
                excerpt: Lots of tools and utilities that take care of the low-level things to allow you to focus on more higher level features.
        - title: Get Involved
          theme: dark
          background_color: "#643fea"
          excerpt: >
              Join the community and help contribute to create a framework that everyone can use
          actions:
              - text: GitHub
                type: outline-secondary
                url: https://github.com/littlektframework/littlekt
---
