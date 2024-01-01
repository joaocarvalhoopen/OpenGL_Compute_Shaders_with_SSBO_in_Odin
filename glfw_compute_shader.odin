/*

OpenGL Compute Shaders in with SSBO Odin
The dream of having something resembling CUDA Computing on the GPU in simple OpenGL on open source drivers. 

How to use compute shaders in OpenGL with SSBO - Shader Storage Buffer Objects ?

Objective:
To perform general computing tasks, of the type of CUDA on the GPU using
Compute Shaders and SSBO - Shader Storage Buffer Objects.

Description:
The following code has a bug and in my open source Linux drivers on a Integrated
AMD GPU inside my CPU AMD Ryzen 4700 G, it crashes the computer. Not fun at all.
But because there is so little information on the internet about how to use the
Compute shaders and SSBO - Shader Storage Buffer Objects, I am posting this code
anyway.

I implemented this code in Odin after doing a lot of research on the internet.
I post here the code and the references that I used to implement it.


There is also a other program inside the directory "opengl_simple_program_working",
that works, I made it from following the learning OpenGL tutorial from the site:
https://learnopengl.com and from one example of Odin of the GLFW library.
That program doesn't use Compute Shaders and SSBO - Shader Storage Buffer Objects,
but it works and it is a good starting point to learn how to use OpenGL in Odin.

Author  : João Nuno Carvalho
Date    : 2024.01.01
License : MIT Open Source License


References:

Medium Article:
https://medium.com/@daniel.coady/compute-shaders-in-opengl-4-3-d1c741998c03


GitHub:
https://github.com/pondodev/opengl_compute/tree/29802608ead55c92184fadfac63042382d5592c3


What is the difference between OpenCL and OpenGL's compute shader?
https://stackoverflow.com/questions/15868498/what-is-the-difference-between-opencl-and-opengls-compute-shader/15874988


[StackOverFlow response]
Those interested in OpenGL arithmetic precision guarantees should regard the ARB_shader_precision extension, introduced in OpenGL 4.1.
See: https://registry.khronos.org/OpenGL/extensions/ARB/ARB_shader_precision.txt 
Droid Coder
 Aug 11, 2019 at 11:22


OpenGL (4.3) compute shader example
http://wili.cc/blog/opengl-cs.html


Compute Shader - Official documentation
https://www.khronos.org/opengl/wiki/Compute_Shader

It's More Fun to Compute
An Introduction to Compute Shaders
https://antongerdelan.net/opengl/compute.html


Mike Bailey
OpenGL Compute Shaders
https://web.engr.oregonstate.edu/~mjb/cs557/Handouts/compute.shader.1pp.pdf


In Python:

Compute Shader Tutorial
https://api.arcade.academy/en/latest/tutorials/compute_shader/index.html

ktyldev - oglc   <-- Cat flynn
https://github.com/ktyldev/oglc


Textures
https://learnopengl.com/Getting-started/Textures


glCreateShader — Creates a shader object
https://registry.khronos.org/OpenGL-Refpages/gl4/html/glCreateShader.xhtml


Shader Storage Buffer Object
https://www.khronos.org/opengl/wiki/Shader_Storage_Buffer_Object


GPU Buffers: Introduction to OpenGL 4.3 Shader Storage Buffers Objects
https://www.geeks3d.com/20140704/tutorial-introduction-to-opengl-4-3-shader-storage-buffers-objects-ssbo-demo/


Buffer Object
https://www.khronos.org/opengl/wiki/Buffer_Object


glTexImage2D — specify a two-dimensional texture image
https://registry.khronos.org/OpenGL-Refpages/gl4/html/glTexImage2D.xhtml


glBindImageTexture — bind a level of a texture to an image unit
https://registry.khronos.org/OpenGL-Refpages/gl4/html/glBindImageTexture.xhtml


Shaders
https://learnopengl.com/Getting-started/Shaders

Compute Shaders - Inputs
https://www.khronos.org/opengl/wiki/Compute_Shader#Inputs

Compute Shaders - local_size
https://www.khronos.org/opengl/wiki/Compute_Shader#Local_size


glGetTexImage — return a texture image
https://registry.khronos.org/OpenGL-Refpages/gl4/html/glGetTexImage.xhtml


*/



package glfw_window

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

import "core:strings"

import "core:mem"


WIDTH  	:: 800
HEIGHT 	:: 450
TITLE 	:: "My Window!"

// @note You might need to lower this to 3.3 depending on how old your graphics card is.
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 5



// Shader programs as strings.

vertex_shader_source : cstring = `#version 330 core
layout (location = 0) in vec3 aPos;
void main()
{ 
   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
`

fragment_shader_source : cstring = `#version 330 core
out vec4 FragColor;
void main()
{
   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
`

// TODO: Compute shader.
compute_shader_source : cstring = `#version 430
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;  

// Structure of the data
struct my_strut_t
{
    vec4 pos;
    vec4 vel;
    vec4 color;
};


// Input buffer
layout (std430, binding=2) buffer shader_data_in
{ 
    my_strut_t items[ 2 ];
} In;


// Output buffer
layout (std430, binding=3) buffer shader_data_out
{ 
    my_strut_t items[ 2 ];
} Out;


void main()
{
    // Get the index of the current item in the buffer.
    int curIndex = int( gl_GlobalInvocationID );

    // Get the current item.
    my_strut_t in_item = In.items[ curIndex ];

    // Map to simple variables.
    vec4 p = in_item.pos.xyzw;
    vec4 v = in_item.vel.xyzw;
    vec4 c = in_item.color.xyzw;
    
    // Create a local copy of the current item to output.
    my_strut_t out_item;

    // Modify the local copy.
    out_item.pos.xyzw   = p.xyzw + vec4( 10.0, 10.0, 10.0, 10.0 );
    out_item.vel.xyzw   = v.xyzw + vec4( 10.0, 10.0, 10.0, 10.0 );
    out_item.color.xyzw = c.xyzw + vec4( 10.0, 10.0, 10.0, 10.0 );

    // Write the local copy to the output buffer.
    Out.items[ curIndex ] = out_item;
}
`


// Struct for SSBO - Shader Storage Buffer Objects
ShaderDataT :: struct {
    pos   : [4]f32,
    vel   : [4]f32,
    color : [4]f32,
}


main :: proc() {
	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	window_handle := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)

	defer glfw.Terminate()
	defer glfw.DestroyWindow(window_handle)

	if window_handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	// Load OpenGL context or the "state" of OpenGL.
	glfw.MakeContextCurrent(window_handle)
	// Load OpenGL function pointers with the specficed OpenGL major and minor version.
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    // jnc begin


    // SSBO - Shader Storage Buffer Objects
    // https://www.geeks3d.com/20140704/tutorial-introduction-to-opengl-4-3-shader-storage-buffers-objects-ssbo-demo/
    //
    // With a GeForce GTX 660, each type of shader (vertex, fragment, geometry, tessellation and compute) can have up to 16 storage blocks.

    // #############
    // Input data for SSBO - Shader Storage Buffer Objects 
    shader_data_in : [2]ShaderDataT

    shader_data_in[0].pos   =  [4]f32 { 1.0, 1.0, 1.0, 1.0 }
    shader_data_in[0].vel   =  [4]f32 { 1.1, 1.1, 1.1, 1.1 }
    shader_data_in[0].color =  [4]f32 { 1.2, 1.2, 1.2, 1.2 }

    shader_data_in[1].pos   =  [4]f32 { 10.0, 10.0, 10.0, 10.0 }
    shader_data_in[1].vel   =  [4]f32 { 10.1, 10.1, 10.1, 10.1 }
    shader_data_in[1].color =  [4]f32 { 10.2, 10.2, 10.2, 10.2 }


    for i in 0 ..< len(shader_data_in) {
        fmt.printf( "shader_data_in[%v].pos   = %v \n", i, shader_data_in[ i ].pos )
        fmt.printf( "shader_data_in[%v].vel   = %v \n", i, shader_data_in[ i ].vel )
        fmt.printf( "shader_data_in[%v].color = %v \n", i, shader_data_in[ i ].color )
    }


    // Creation and initialization of a SSBO "in":
    ssbo_in: u32 = 0
    gl.GenBuffers( 1, &ssbo_in )
    gl.BindBuffer( gl.SHADER_STORAGE_BUFFER, ssbo_in )
    gl.BufferData( gl.SHADER_STORAGE_BUFFER, size_of( shader_data_in ), &shader_data_in, gl.DYNAMIC_COPY )
    gl.BindBuffer( gl.SHADER_STORAGE_BUFFER, 0 );  // unbind


    // Fill by write to the SSBO "in" Buffer.

    // SSBO update: we get the pointer on the GPU memory and we copy our data:
    gl.BindBuffer( gl.SHADER_STORAGE_BUFFER, ssbo_in )
    // GLvoid* p = glMapBuffer(GL_SHADER_STORAGE_BUFFER, GL_WRITE_ONLY);
    ptr_in : rawptr = gl.MapBuffer( gl.SHADER_STORAGE_BUFFER, gl.WRITE_ONLY )
    mem.copy(ptr_in, &shader_data_in, size_of( shader_data_in ) )
    gl.UnmapBuffer( gl.SHADER_STORAGE_BUFFER )


    // #############
    // output data for SSBO - Shader Storage Buffer Objects 
    shader_data_out : [2]ShaderDataT

    // Creation and initialization of a SSBO out:
    ssbo_out: u32 = 1
    gl.GenBuffers( 2, &ssbo_out )
    gl.BindBuffer( gl.SHADER_STORAGE_BUFFER, ssbo_out )
    gl.BufferData( gl.SHADER_STORAGE_BUFFER, size_of( shader_data_out ), &shader_data_out, gl.DYNAMIC_COPY )
    gl.BindBuffer( gl.SHADER_STORAGE_BUFFER, 0 );   // unbind



    // #############
    // Compute shader
    compute_shader : u32;
    compute_shader = gl.CreateShader( gl.COMPUTE_SHADER )
    gl.ShaderSource( compute_shader, 1, &compute_shader_source, nil )
    gl.CompileShader( compute_shader )

    // check for shader compile errors
    success : i32
    info_log : [512]u8   // char
    gl.GetShaderiv( compute_shader, gl.COMPILE_STATUS, &success )
    if ! bool( success ) {
        gl.GetShaderInfoLog(compute_shader, 512, nil, raw_data( info_log[:] ) )// &info_log)
        
        err_msg, err := strings.clone_from_bytes(info_log[ : ] )
        if err != nil {
            fmt.eprintln("Failed to convert shader info log to string.")
            return
        }

        fmt.printf( "ERROR::SHADER::COMPUTE::COMPILATION_FAILED\n %v \n", err_msg )
        return
    }
    

    // ##############
    // Shader Program
    // link shaders
    shader_program_1 : u32 = gl.CreateProgram( )
    gl.AttachShader( shader_program_1, compute_shader )
    gl.LinkProgram( shader_program_1 )
    
    // check for linking errors
    gl.GetProgramiv( shader_program_1, gl.LINK_STATUS, &success)
    if ! bool( success ) {
        gl.GetProgramInfoLog( shader_program_1, 512, nil, raw_data( info_log[ : ] ) )
        
        err_msg, err := strings.clone_from_bytes(info_log[ : ] )
        if err != nil {
            fmt.eprintln( "Failed to convert shader program info log to string." )
            return
        }

        fmt.printf( "ERROR::SHADER::PROGRAM::LINKING_FAILED\n %v \n", err_msg )
        return
    }

    gl.DeleteShader( compute_shader )
    


    // render loop
    // -----------

    // Execute the compute shader program.
    gl.UseProgram( shader_program_1 );
    
    // TODO: See if this is correct? OR do I have to count the number of threads in each group?
    num_goups_x : u32 = u32( len(shader_data_in) )
    gl.DispatchCompute( num_goups_x , 1, 1 )

    // TODO: 

    // make sure writing to the output SSBO out buffer finished before read from the host.
    // gl.MemoryBarrier( gl.ALL_BARRIER_BITS )   //  GL_SHADER_IMAGE_ACCESS_BARRIER_BIT

    // gl.MemoryBarrier( gl.SHADER_STORAGE_BARRIER_BIT )



    // ###############
    // Read from the SSBO out Buffer.

    // SSBO update: we get the pointer on the GPU memory and we copy our data:
    gl.BindBuffer( gl.SHADER_STORAGE_BUFFER, ssbo_out )
    // GLvoid* p = glMapBuffer(GL_SHADER_STORAGE_BUFFER, GL_WRITE_ONLY);
    ptr_out : rawptr = gl.MapBuffer( gl.SHADER_STORAGE_BUFFER, gl.READ_ONLY )
    mem.copy( &shader_data_out, ptr_out, size_of( shader_data_out ) )
    gl.UnmapBuffer( gl.SHADER_STORAGE_BUFFER )

    for i in 0 ..< len(shader_data_out) {
        fmt.printf( "shader_data_out[%v].pos   = %v \n", i, shader_data_out[ i ].pos )
        fmt.printf( "shader_data_out[%v].vel   = %v \n", i, shader_data_out[ i ].vel )
        fmt.printf( "shader_data_out[%v].color = %v \n", i, shader_data_out[ i ].color )
    }

    // Delete the SSBO Buffer Objects
    gl.DeleteBuffers( 1, &ssbo_in )
    gl.DeleteBuffers( 2, &ssbo_out )
    gl.DeleteProgram( shader_program_1 )




    // To be able to read from or write to a SSBO, the following steps are required:
    //
    // 1 – find the storage block index:
    
    // block_index: u32 = 0
    // block_index = gl.GetProgramResourceIndex( program, gl.SHADER_STORAGE_BLOCK, "shader_data")




    /*
    
    // 2 – connect the shader storage block to the SSBO: we tell the shader on which binding point it will find the SSBO. In our case, the SSBO is bound on the point 2:

    ssbo_binding_point_index : u32 = 2;
    gl.ShaderStorageBlockBinding( program, block_index, ssbo_binding_point_index )
    
    // Actually this last step is not required: the binding point can be hard coded directly in the GLSL shader in the buffer layout:

    layout (std430, binding=2) buffer shader_data
    {
        ...
    }

    */





    // build and compile our 2nd shader program
    // ------------------------------------
    // vertex shader
    vertex_shader : u32 = gl.CreateShader( gl.VERTEX_SHADER )
    gl.ShaderSource( vertex_shader, 1, &vertex_shader_source, nil )
    gl.CompileShader( vertex_shader )
    // check for shader compile errors
    
    // success : i32
    // info_log : [512]u8   // char
    
    gl.GetShaderiv( vertex_shader, gl.COMPILE_STATUS, &success )
    if ! bool( success ) {
        gl.GetShaderInfoLog(vertex_shader, 512, nil, raw_data( info_log[:] ) )// &info_log)
        
        err_msg, err := strings.clone_from_bytes(info_log[ : ] )
        if err != nil {
            fmt.eprintln("Failed to convert shader info log to string.")
            return
        }

        // std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
        fmt.printf( "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n %v \n", err_msg )
    }

    // fragment shader
    fragment_shader : u32 = gl.CreateShader( gl.FRAGMENT_SHADER )
    gl.ShaderSource( fragment_shader, 1, &fragment_shader_source, nil )
    gl.CompileShader( fragment_shader )
    // check for shader compile errors
    gl.GetShaderiv( fragment_shader, gl.COMPILE_STATUS, &success)
    if ! bool( success ) {
        gl.GetShaderInfoLog( fragment_shader, 512, nil, raw_data( info_log[ : ] ) )

        err_msg, err := strings.clone_from_bytes(info_log[ : ])
        if err != nil {
            fmt.eprintln("Failed to convert shader info log to string.")
            return
        }

        // std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
        fmt.printf( "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n %v \n", err_msg )
    }

    // link shaders
    shader_program_2 : u32 = gl.CreateProgram( )
    gl.AttachShader( shader_program_2, vertex_shader )
    gl.AttachShader( shader_program_2, fragment_shader )
    gl.LinkProgram( shader_program_2 )
    
    // check for linking errors
    gl.GetProgramiv( shader_program_2, gl.LINK_STATUS, &success)
    if ! bool( success ) {
        gl.GetProgramInfoLog( shader_program_2, 512, nil, raw_data( info_log[ : ] ) )
        
        err_msg, err := strings.clone_from_bytes(info_log[ : ] )
        if err != nil {
            fmt.eprintln( "Failed to convert shader info log to string." )
            return
        }
        
        // std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;

        fmt.printf( "ERROR::SHADER::PROGRAM::LINKING_FAILED\n %v \n", err_msg )
    }
    gl.DeleteShader( vertex_shader )
    gl.DeleteShader( fragment_shader )
 


    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    vertices :[9]f32 = [?]f32{ -0.5, -0.5, 0.0, // left  
                                0.5, -0.5, 0.0, // right 
                                0.0,  0.5, 0.0  // top   
                             }

    VBO, VAO : u32
    gl.GenVertexArrays( 1, &VAO )
    gl.GenBuffers( 1, &VBO )
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.BindVertexArray( VAO )

    gl.BindBuffer( gl.ARRAY_BUFFER, VBO )
    gl.BufferData( gl.ARRAY_BUFFER, size_of( vertices ), rawptr( &vertices ), gl.STATIC_DRAW )

    gl.VertexAttribPointer( 0, 3, gl.FLOAT, gl.FALSE, 3 * size_of( f32 ),  uintptr( 0 ) )  // (void*)0   //   rawptr( 0 )
    gl.EnableVertexAttribArray( 0 )

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    gl.BindBuffer( gl.ARRAY_BUFFER, 0 ) 

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    gl.BindVertexArray( 0 ) 


    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    // render loop
    // -----------



    // jnc end

	for !glfw.WindowShouldClose(window_handle) {
		// Process all incoming events like keyboard press, window resize, and etc.
		glfw.PollEvents()

        // jnc begin

        process_input( window_handle )

        // gl.Viewport(0, 0, WIDTH - 100, HEIGHT - 200)


        // jnc end

        // Render
		// gl.ClearColor(0.5, 0.0, 1.0, 1.0)
		
        gl.ClearColor( 0.2, 0.3, 0.3, 1.0 )
        gl.Clear(gl.COLOR_BUFFER_BIT)


        // jnc begin


        // draw our first triangle
        gl.UseProgram( shader_program_2 )
        // seeing as we only have a single VAO there's no need to bind it every time,
        // but we'll do so to keep things a bit more organized.
        gl.BindVertexArray( VAO ) 
        gl.DrawArrays( gl.TRIANGLES, 0, 3 )
        // glBindVertexArray( 0 ); // no need to unbind it every time 


        // jnc end

		glfw.SwapBuffers(window_handle)
	}

    // optional: de-allocate all resources once they've outlived their purpose:
    // ------------------------------------------------------------------------
    gl.DeleteVertexArrays( 1, &VAO )
    gl.DeleteBuffers( 1, &VBO )
    gl.DeleteProgram( shader_program_2 )

}

process_input :: proc ( window_handle : glfw.WindowHandle ) {
    if glfw.GetKey( window_handle, glfw.KEY_ESCAPE ) == glfw.PRESS {
        glfw.SetWindowShouldClose( window_handle, true )
    }
}



