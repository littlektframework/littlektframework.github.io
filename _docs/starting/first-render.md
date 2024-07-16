---
title: First Render
permalink: /docs/starting/first-render
---

This tutorial assumes the [First Application](/docs/starting/first-application) has been completed. 

# Rendering

The initial setup of render seems a bit daunting in WebGPU, especially if we are coming from an OpenGL background. In reality, it isn't as bad as it seems. LittleKt takes care of a lot of the work for us but also keeps things low-level enough that we can build on top of it. Let's render something!

```kotlin
class MyGame(context: Context) : ContextListener(context) {

    override suspend fun Context.start() {
        val texture = Textures.white
        // optionally, if you have a texture ready to be loaded, place it in the /commonMain/resources directory and load it
        val texture = resourceVfs["texture.png"].readTexture()

        val device = graphics.device // LittleKt creates a WebGPU adapter & a device from it. It's as simple as referencing it.
        val surfaceCapability = graphics.surfaceCapabilities // we grab the current graphics surface capabilities
        val preferredFromat = graphics.preferredFormat // what TextureFormat the surface prefers

        // then we configure the surface
        graphics.configureSurface(
            TextureUsage.RENDER_ATTACHMENT,
            preferredFormat,
            PresentMode.FIFO,
            surfaceCapabilities.alphaModes[0]
        )

        // now we can render. Let's create a SpriteBatch that can render our texture to the surface
        val batch = SpriteBatch(device, graphics, preferredFormat)

        // we can also create a viewport to manipulate how it's displayed on the surface.
        val viewport = ExtendViewport(graphics.width, graphics.height)
        val camera = viewport.camera // the viewport uses an orthographic camera internally

        // we can then configure the surface everytime the window is resized, as well as our viewport & camera
        onResize { width, height ->
            viewport.update(width, height, centerCamera = true) // this also updates the camera
            graphics.configureSurface(
                TextureUsage.RENDER_ATTACHMENT,
                preferredFormat,
                PresentMode.FIFO,
                surfaceCapabilities.alphaModes[0]
            )
        }

        // now we render
        onUpdate { dt -> // this adds an updater that is called on every frame
            // grab the current surface texture
            val surfaceTexture: SurfaceTexture = graphics.surface.getCurrentTexture()
            val swapChainTexture: WebGPUTexture = checkNotNull(surfaceTexture.texture) // we need the underlying WebGPU texture, which may be null
            val frame: TextureView = swapChainTexture.createView() // we create the view of the texture! We can now use it as a color attachment in a render pass!

            val commandEncoder: CommandEncoder = device.createCommandEncoder // handles creating commands to present to the surface
            val renderPassEncoder =
                commandEncoder.beginRenderPass(
                    desc =
                        RenderPassDescriptor(
                            listOf(
                                RenderPassColorAttachmentDescriptor(
                                    view = frame, // we are using the surface frame here!
                                    loadOp = LoadOp.CLEAR, // this indicates to clear the view each time. think of this as glClear()
                                    storeOp = StoreOp.STORE, // this indicates to store the results of the rendre pass to the output attachment, which is the frame
                                    clearColor = // what color to clear the with. Note: how we handle srgb vs non-srgb colors
                                        if (preferredFormat.srgb) Color.DARK_GRAY.toLinear()
                                        else Color.DARK_GRAY
                                )
                            )
                        )
                ) // begin a new render pass, via the command encoder

            camera.update() // ensure our camera is fully up-to-date
            // use our batch to begin drawing by passing in our combined view & projection matrix
            batch.begin(camera.viewProjection)
            batch.draw(texture, x = 25f, y = 25f, scaleX = 50f, scaleY = 50f)
            // flush the render pass. This will make all the draw calls to the underlying mesh with the g
            batch.flush(renderPassEncoder)
            batch.end() // ensure we end the batch drawing
            renderPassEncoder.end() // render pass is done so we end it

            // we aren't creating anymore render passes, so we can finish the command encoder
            val commandBuffer = commandEncoder.finish() // this returns a list of commands we need to submit

            device.queue.submit(commandBuffer) // using the device, we submit the commands to the queue
            graphics.surface.present() // inform the surface to present

            // we must release all the resources we just created this frame. This must be done each frame.
            commandBuffer.release()
            renderPassEncoder.release()
            commandEncoder.release()
            frame.release()
            swapChainTexture.release()
        }
    }
}
```