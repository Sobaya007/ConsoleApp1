import Import;
import core.thread;
import sbylib;

const int window_width = 800;
const int window_height = 600;

//static this()
//{
//    DerelictFT.load();
//} 
//
//void main(string[] args)
//{
//    FT_Library handle;
//    int v0,v1,v2;
//    FT_Init_FreeType(&handle);
//    FT_Library_Version(handle, &v0, &v1, &v2);
//    writeln(v0," ",v1," ",v2);
//}

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

	SbyInit(window, 10);

	{
		//if (window_width < window_height) {
		//    glViewport(0, (window_height - window_width) /2, window_width, window_width);
		//} else {
		//    glViewport((window_width - window_height) /2, 0, window_height, window_height);
		//}
		glViewport(0,0,window_width, window_height);
	}

	CurrentCamera = new PerspectiveCamera(1, PI_4, 1, 30);
	with (CurrentCamera) {
		Pos = vec3(0,1,3) * 3;
		Target = vec3(0, 0, 0);
		VecY = vec3(0,1, 0);
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
	box += vec3(0,1,0) * 3;

	auto plane = new Plane(ShaderStore.getShader("Check"));
	plane *= vec3(1,1,1) * 10;
	plane -= vec3(0,0.1, 0);

	auto sphere = new ElasticSphere;


	auto ball = new Sphere;

	auto cameraManipulator = new CameraChaser(CurrentCamera);
	cameraManipulator.focus = sphere;
	ManipulatorManager.Add(cameraManipulator);
	TextureObject compass = new TextureObject(0xff, 0xff, GL_RGBA); 
	FrameBufferObject fbo = new FrameBufferObject();

	glLineWidth(5f);

	MainLoop(() {

		glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		box.Draw();
		plane.Draw();
		sphere.Draw();
		//ball.Draw();

		fbo.AttachTextureAsColor(compass);
		fbo.Write(0xff, 0xff,{
			glClearColor(0, 0, 0, 0);
			glClear(GL_COLOR_BUFFER_BIT);
			auto shader = ShaderStore.getShader("Compass");
			shader.SetUniformMatrix!(4, "mView")(CurrentCamera.GetViewMatrix.array);
			DrawRectWithShader(0xff/2+1, 0xff/2+1, 0xff, 0xff, shader);
		});
		DrawImage(window_width-50, 50, 100, 100, compass);

		Ray ray = CurrentCamera.GetCameraRay(CurrentWindow.getMousePos);
		auto p = ray.GetPos - ray.GetPos.y / ray.vector.y * ray.vector;
		ball.Pos = p;
		
		fpsCounter.Update();
		window.glfwSetWindowTitle(("FPS:[" ~ to!string(fpsCounter.GetFPS) ~ "]").toStringz);
	});
	return true;
}

auto InitGLFW(in int window_width, in int window_height) {

	DerelictGL.load();
	DerelictGL3.load();
	DerelictGLFW3.load();
	//DerelictFT.load();
	//DerelictSDL2.load();

	if (!glfwInit()) {
		writeln("Failed to initialize GLFW");

		return null;
	}

	auto window = glfwCreateWindow(window_width, window_height,"Hello, D world!", null, null);
	if(!window){
		writeln("Failed to create window");
		return null;
	}
	glfwSetWindowPos(window,0, 30);


	glfwMakeContextCurrent(window);


	auto glver = DerelictGL.reload();
	if(glver < derelict.opengl3.gl3.GLVersion.GL40){
		return null;
	}
	return window;
}
