package glfw_window

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

import "core:strings"

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


    // build and compile our shader program
    // ------------------------------------
    // vertex shader
    vertex_shader : u32 = gl.CreateShader( gl.VERTEX_SHADER )
    gl.ShaderSource( vertex_shader, 1, &vertex_shader_source, nil )
    gl.CompileShader( vertex_shader )
    // check for shader compile errors
    success : i32
    info_log : [512]u8   // char
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
    shader_program : u32 = gl.CreateProgram( )
    gl.AttachShader( shader_program, vertex_shader )
    gl.AttachShader( shader_program, fragment_shader )
    gl.LinkProgram( shader_program )
    
    // check for linking errors
    gl.GetProgramiv( shader_program, gl.LINK_STATUS, &success)
    if ! bool( success ) {
        gl.GetProgramInfoLog( shader_program, 512, nil, raw_data( info_log[ : ] ) )
        
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
        gl.UseProgram( shader_program )
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
    gl.DeleteProgram( shader_program )
}

process_input :: proc ( window_handle : glfw.WindowHandle ) {
    if glfw.GetKey( window_handle, glfw.KEY_ESCAPE ) == glfw.PRESS {
        glfw.SetWindowShouldClose( window_handle, true )
    }
}



