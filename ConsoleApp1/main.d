import Import;
import core.thread;
import sbylib.imports;

const int window_width = 800;
const int window_height = 600;

void main()
{
	if (!GameMain()) {
		while (true) {}
	}
}

bool GameMain() {

	auto window = InitGLFW(window_width, window_height);
	if (!window) return false;
	glfwSetErrorCallback((error, description){ 
		writeln(description);
	});

	SbyInit(window, 16);

	{
		if (window_width < window_height) {
			glViewport(0, (window_height - window_width) /2, window_width, window_width);
		} else {
			glViewport((window_width - window_height) /2, 0, window_height, window_height);
		}
	}

	CurrentCamera = new PerspectiveCamera(1, PI_4, 1, 30);
	with (CurrentCamera) {
		Eye = vec3(0,1,3);
		Target = vec3(0, 0, 0);
		Up = vec3(0,1, 0);
	}

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glEnable(GL_BLEND);
	glCullFace(GL_BACK);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	ShaderStore.Init;

	auto fpsCounter = new FpsCounter!(100);
	auto box = new Box;
	vec3 scale = vec3(1,1,1) * 0.5f;
	box *= scale;
	box.mat *= mat4.RotAxisAngle(vec3(1,1,1), 45);
	box += vec3(0,1,0);

	auto plane = new Plane(ShaderStore.getShader("Check"));
	plane *= vec3(1,1,1) * 10;

	MainLoop(() {

		glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		box.Draw();
		plane.Draw();
		
		fpsCounter.Update();
		window.glfwSetWindowTitle(("FPS:[" ~ to!string(fpsCounter.GetFPS) ~ "]").toStringz);
		CurrentCamera.KeyMove();
	});
	return true;
}

auto InitGLFW(in int window_width, in int window_height) {

	DerelictGL.load();
	DerelictGL3.load();

	DerelictGLFW3.load();


	if (!glfwInit()) {
		writeln("Failed to initialize GLFW");

		return null;
	}

	auto window = glfwCreateWindow(window_width, window_height,"Hello, D world!", null, null);
	if(!window){
		writeln("Failed to create window");
		return null;
	}
	glfwSetWindowPos(window,100, 100);


	glfwMakeContextCurrent(window);


	auto glver = DerelictGL.reload();
	if(glver < derelict.opengl3.gl3.GLVersion.GL40){
		return null;
	}
	return window;
}
