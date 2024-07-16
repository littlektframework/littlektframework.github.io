---
title: Shaders
permalink: /docs/shading/shaders
---

LittleKt offers utility classes for writing GLSL code, called shaders, in order to render items onto the screen. By default, the `SpriteBatch` class uses its own default shader to handle rendering. If we forgo using a `SpriteBatch`, we would have to setup the render pipeline ourselves. But in this article, we will show how to build upon the LittleKt `Shader` API.

## What are Shaders

Shaders are small programs written in WGSL, which is a C-like language, that is then loaded onto the GPU and processes data in order to render things onto the screen. For more info on what shaders are and how to use a shader check out the shader article on [w3](https://www.w3.org/TR/WGSL/).


## Creating Shaders

Using the open class, `Shader` we create custom shaders that handle most of the pipeline and bindings creation for us. All we need to do is pass along the shader source, a `Device` and the "layout" descriptors.

### Shader

This is a simplified example that skips showing all the setup. But if we know WebGPU, we can create our custom pipeline to handle it all.

```kotlin
val shader = Shader(device, MY_SHADER_SRC, bindingGroupLayoutDescritors)
val renderPipeline = device.createRenderPipeline(...) // pipeline setup
```

#### Buffer Updates

A Shader has an open function, that expects a map of data, to allow updating specific buffers used in the shader.

```kotlin
    /**
     * Do any buffer updates here.
     *
     * @param data a data map that can include any data that is needed in order to update bindings ,
     *   using a string as a key.
     */
    open fun update(data: Map<String, Any>) = Unit
```

### SpriteShader

A `SpriteShader` is an abstract `Shader` that expects a camera uniform and a texture to be passed in. This type of shader is used internally by `SpriteBatch` but may extended to create custom SpriteShaders. It contains functions to handle updating the internal camera uniform buffer via `SpriteShader.updateCameraUniform(viewProjection: Mat4)`. But this `SpriteShader` overrides the `Shader.update(data: Map<String, Any>)` function and calls `updateCameraUniform()` automatically.

```kotlin
    class ColorShader(device: Device) :
        SpriteShader(
            device,
            src =
                """
        struct CameraUniform {
            view_proj: mat4x4<f32>
        };
        @group(0) @binding(0)
        var<uniform> camera: CameraUniform; // SpriteShader expects a uniform for camera
        
        struct VertexOutput {
            @location(0) color: vec4<f32>,
            @location(1) uv: vec2<f32>,
            @builtin(position) position: vec4<f32>,
        };
                   
        @vertex
        fn vs_main(
            @location(0) pos: vec3<f32>,
            @location(1) color: vec4<f32>,
            @location(2) uvs: vec2<f32>) -> VertexOutput {
            
            var output: VertexOutput;
            output.position = camera.view_proj * vec4<f32>(pos.x, pos.y, 0, 1);
            output.color = color;
            output.uv = uvs;
            
            return output;
        }
        
        @group(1) @binding(0) // expects a texture
        var my_texture: texture_2d<f32>;
        @group(1) @binding(1) // expects a sampler
        var my_sampler: sampler;
        
        @fragment
        fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
            return textureSample(my_texture, my_sampler, in.uv) * vec4<f32>(1, 0, 0, 1);
        }
        """,
            layout =
                listOf(
                    BindGroupLayoutDescriptor(
                        listOf(BindGroupLayoutEntry(0, ShaderStage.VERTEX, BufferBindingLayout())) // camera binding
                    ),
                    BindGroupLayoutDescriptor(
                        listOf(
                            BindGroupLayoutEntry(0, ShaderStage.FRAGMENT, TextureBindingLayout()), // texture binding
                            BindGroupLayoutEntry(1, ShaderStage.FRAGMENT, SamplerBindingLayout()) // sampler binding
                        )
                    )
                )
        ) {
            // we must create new bind groups with the given texture based on the spriete layout
        override fun MutableList<BindGroup>.createBindGroupsWithTexture(
            texture: Texture,
            data: Map<String, Any>
        ) {
            add(
                device.createBindGroup(
                    BindGroupDescriptor(
                        layouts[0],
                        listOf(BindGroupEntry(0, cameraUniformBufferBinding)) // we set the camera unfirom based on group & binding we set in the WGSL source
                    )
                )
            )
            add(
                device.createBindGroup(
                    BindGroupDescriptor(
                        layouts[1],
                        listOf(BindGroupEntry(0, texture.view), BindGroupEntry(1, texture.sampler)) // we set the texture & sampler required in the WGSL source
                    )
                )
            )
        }

        // when this is called we must set our bind groups, in the correct order on the given render pass
        override fun setBindGroups(encoder: RenderPassEncoder, bindGroups: List<BindGroup>) {
            encoder.setBindGroup(0, bindGroups[0])
            encoder.setBindGroup(1, bindGroups[1])
        }
    }
```

And we can use the new shader in a `SpriteBatch` quite easily:

```kotlin
val coloredShader = ColoredShader(device)

// onUpdate:
val renderPassEncoder = ... 
batch.shader = coloredShader
batch.begin()
batch.draw(myTexture, 0f, 0f)
batch.useDefaultShader()
batch.draw(anotherTexture, 50f, 50f)
batch.flush(renderPassEncoder)
batch.end()
renderPassEncoder.end()
```