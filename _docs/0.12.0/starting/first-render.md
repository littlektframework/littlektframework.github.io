---
title: First Render
permalink: /docs/0.12.0/starting/first-render
---

This tutorial assumes the [First Application](/docs/0.12.0/starting/first-application) has been completed. 

# Rendering

The initial setup of render seems a bit daunting in WebGPU, especially if we are coming from an OpenGL background. In reality, it isn't as bad as it seems. LittleKt takes care of a lot of the work for us but also keeps things low-level enough that we can build on top of it. Let's render something!

```kotlin
import com.littlekt.Context
import com.littlekt.ContextListener
import com.littlekt.configureSurfaceOnResize
import com.littlekt.file.vfs.readTexture
import com.littlekt.graphics.Color
import com.littlekt.graphics.webgpu.*
import com.littlekt.graphics.g2d.*
import com.littlekt.renderFrame
import com.littlekt.resources.Textures
import com.littlekt.surfaceColor
import com.littlekt.util.viewport.ExtendViewport

class MyGame(context: Context) : ContextListener(context) {

    override suspend fun Context.start() {
        val texture = Textures.white
        // optionally, if you have a texture ready to be loaded, place it in the /commonMain/resources directory and load it
        val texture = resourceVfs["texture.png"].readTexture()

        val device = graphics.device // LittleKt creates a WebGPU adapter & a device from it. It's as simple as referencing it.
        val preferredFormat = graphics.preferredFormat // what TextureFormat the surface prefers

        // configures the surface with the preferred format and configures it again everytime the window is resized
        configureSurfaceOnResize()

        // now we can render. Let's create a SpriteBatch that can render our texture to the surface
        val batch = SpriteBatch(device, graphics, preferredFormat)

        // we can also create a viewport to manipulate how it's displayed on the surface.
        val viewport = ExtendViewport(graphics.width, graphics.height)
        val camera = viewport.camera // the viewport uses an orthographic camera internally

        // we update our viewport & camera everytime the window is resized
        onResize { width, height ->
            viewport.update(width, height, centerCamera = true) // this also updates the camera
        }

        // what color to clear the frame with. Note: this handles srgb vs non-srgb surfaces for us
        val clearColor = graphics.surfaceColor(Color.DARK_GRAY)

        // now we render
        onUpdate { dt -> // this adds an updater that is called on every frame
            // renderFrame grabs the current surface texture and gives us a view of it (the frame) & a command encoder
            renderFrame { frame, commandEncoder ->
                // begin a new render pass, via the command encoder, that clears the frame each time. think of this as glClear()
                val renderPassEncoder =
                    commandEncoder.beginRenderPass(RenderPassDescriptor(colorAttachment(frame, clearColor)))

                camera.update() // ensure our camera is fully up-to-date
                // use our batch to begin drawing by passing in our combined view & projection matrix
                batch.begin(camera.viewProjection)
                batch.draw(texture, x = 25f, y = 25f, scaleX = 50f, scaleY = 50f)
                // flush the render pass. This will make all the draw calls to the underlying mesh with the g
                batch.flush(renderPassEncoder)
                batch.end() // ensure we end the batch drawing
                renderPassEncoder.end() // render pass is done so we end it
                renderPassEncoder.release()
            } // the commands are submitted, the surface is presented & the frame resources are released here
        }
    }
}
```

## Under the hood

`renderFrame` handles the raw WebGPU steps for each frame. It gets the current surface texture with `graphics.surface.getCurrentTexture()`, skips the frame if it isn't ready (or configures the surface again if it's outdated or lost), creates the frame view and a `CommandEncoder`, then finishes the encoder, submits the commands to `device.queue`, calls `graphics.surface.present()`, and releases everything.

`colorAttachment(view, clearColor)` creates a `RenderPassColorAttachmentDescriptor` that clears the view to `clearColor` and stores the results. Leaving out the `clearColor` loads the existing contents of the view instead, which is useful for drawing on top of a previous pass.

```kotlin
colorAttachment(frame, clearColor) // LoadOp.CLEAR & StoreOp.STORE
colorAttachment(frame) // LoadOp.LOAD & StoreOp.STORE
```
