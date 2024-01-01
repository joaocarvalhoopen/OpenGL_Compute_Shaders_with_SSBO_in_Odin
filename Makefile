all:
	odin build . -out:glfw_test01.exe

clean:
	rm -f glfw_test01.exe

run:
	./glfw_test01.exe