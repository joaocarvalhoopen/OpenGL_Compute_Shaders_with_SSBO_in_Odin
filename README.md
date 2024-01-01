## OpenGL Compute Shaders with SSBO in Odin
The dream of having something resembling CUDA Computing on the GPU in simple OpenGL on open source drivers. 

## How to use compute shaders in OpenGL with SSBO - Shader Storage Buffer Objects?

## Objective
To perform general computing tasks, of the type of CUDA on the GPU using
Compute Shaders and SSBO - Shader Storage Buffer Objects.

## Description
The following code has a bug and in my open source Linux drivers on a Integrated
AMD GPU inside my CPU AMD Ryzen 4700 G, it crashes the computer. Not fun at all.
But because there is so little information on the internet about how to use the
Compute shaders and SSBO - Shader Storage Buffer Objects, I am posting this code
anyway.<br>

I implemented this code in Odin after doing a lot of research on the internet. <br>
I post here the code and the references that I used to implement it.<br>


There is also a other program inside the directory "opengl_simple_program_working",
that works, I made it from following the learning OpenGL tutorial from the site:
https://learnopengl.com and from one example of Odin of the GLFW library.
That program doesn't use Compute Shaders and SSBO - Shader Storage Buffer Objects,
but it works and it is a good starting point to learn how to use OpenGL in Odin.


## References

- Medium Article on Compute Shaders with texture buffers, no SSBO. <br>
  https://medium.com/@daniel.coady/compute-shaders-in-opengl-4-3-d1c741998c03


- GitHub of the previous article<br>
  https://github.com/pondodev/opengl_compute/tree/29802608ead55c92184fadfac63042382d5592c3


- What is the difference between OpenCL and OpenGL's compute shader?<br>
  https://stackoverflow.com/questions/15868498/what-is-the-difference-between-opencl-and-opengls-compute-shader/15874988


- StackOverFlow response - To resolve the fact than OpenGL calculation can be less accurate then IEEE float 32<br>
  Those interested in OpenGL arithmetic precision guarantees should regard the ARB_shader_precision extension, introduced in OpenGL 4.1.a<br>
  See: https://registry.khronos.org/OpenGL/extensions/ARB/ARB_shader_precision.txt <br>
  Droid Coder <br>
  Aug 11, 2019 at 11:22 <br>

 - OpenGL (4.3) compute shader example <br>
   http://wili.cc/blog/opengl-cs.html


- Compute Shader - Official documentation <br>
  https://www.khronos.org/opengl/wiki/Compute_Shader

- It's More Fun to Compute <br>
  An Introduction to Compute Shaders <br>
  https://antongerdelan.net/opengl/compute.html

- Mike Bailey <br>
  OpenGL Compute Shaders <br>
  https://web.engr.oregonstate.edu/~mjb/cs557/Handouts/compute.shader.1pp.pdf


- In Python - Compute Shader Tutorial <br>
  https://api.arcade.academy/en/latest/tutorials/compute_shader/index.html

- ktyldev - oglc   -- Cat flynn <br>
  https://github.com/ktyldev/oglc


- Textures <br>
  https://learnopengl.com/Getting-started/Textures

- glCreateShader — Creates a shader object <br>
  https://registry.khronos.org/OpenGL-Refpages/gl4/html/glCreateShader.xhtml

- Shader Storage Buffer Object <br>
  https://www.khronos.org/opengl/wiki/Shader_Storage_Buffer_Object

- GPU Buffers: Introduction to OpenGL 4.3 Shader Storage Buffers Objects <br>
  https://www.geeks3d.com/20140704/tutorial-introduction-to-opengl-4-3-shader-storage-buffers-objects-ssbo-demo/

- Buffer Object <br>
  https://www.khronos.org/opengl/wiki/Buffer_Object

- glTexImage2D — specify a two-dimensional texture image <br>
  https://registry.khronos.org/OpenGL-Refpages/gl4/html/glTexImage2D.xhtml

- glBindImageTexture — bind a level of a texture to an image unit <br>
  https://registry.khronos.org/OpenGL-Refpages/gl4/html/glBindImageTexture.xhtml

- Shaders <br>
  https://learnopengl.com/Getting-started/Shaders

- Compute Shaders - Inputs <br>
  https://www.khronos.org/opengl/wiki/Compute_Shader#Inputs

- Compute Shaders - local_size <br>
  https://www.khronos.org/opengl/wiki/Compute_Shader#Local_size

- glGetTexImage — return a texture image <br>
  https://registry.khronos.org/OpenGL-Refpages/gl4/html/glGetTexImage.xhtml


## License
MIT Open Source License

## Have fun
Best regards, <br>
João Nuno Carvalho
