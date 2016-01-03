import Import;
import core.thread;
import SbyFluidUtils;
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

	glViewport(0, 0, window_width, window_height);

	//auto tex = new TextureObject("Resource/810.jpg");
	//
	//ShaderProgram colorInit = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Simple.frag", ShaderProgram.InputType.FilePath);
	//colorInit.SetTexture(tex);
	//glBindFramebuffer(GL_FRAMEBUFFER, 0);
	//Fluid!float fluid = new Fluid!float("Shader/DisappearColor.frag",
	//                                    "Shader/Fluid/VelocityInit.frag"
	//                                    , 128);
	//
	//DistanceFieldMaterial dfm = new DistanceFieldMaterial(
	//                                                      "TestName",  
	//                                                      "vec2 t = vec2(0.5, 0.1);
	//                                                      vec2 q = vec2(length(pos.xz)-t.x,pos.y);
	//                                                      return length(q)-t.y;", 
	//                                                      "return vec4(getNormal(pos) * 0.5 + 0.5, 1);", 
	//                                                      "int x;" 
	//                                                      );
	//
	//ScreenRenderer renderer = new ScreenRenderer(window);
	//renderer.RegisterMaterial(dfm);
	//renderer.Update();
	//
	//SphereBillboard obj = new SphereBillboard( dfm, true );
	//with (obj) {
	//    Radius = 3.0;
	//    mWorld = mat4.Translation(vec3(1,0,0));
	//}
	//renderer.RegisterObject(obj);
	//VertexArrayObject!float vao = new VertexArrayObject!float(4);
	//vao.shaderProgram = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/TestShader.frag", ShaderProgram.InputType.FilePath);
	//vao.SetTexture(fluid.colorTexture);
	//vao.UpdateVertex([
	//    -1,-1,0, 1,
	//    -1, 1,0, 1,
	//    1,-1,0, 1,
	//    1, 1,0, 1
	//]);

	CurrentCamera = new PerspectiveCamera(1, PI_4, 1, 30);
	with (CurrentCamera) {
		Eye = vec3(0,0,1);
		Target = vec3(0, 0, 0);
		Up = vec3(0,1, 0);
	}

	auto fpsCounter = new FpsCounter!(100);
	auto box = new Box;
	vec3 scale = vec3(1,1,1) * 0.5f;
	box *= scale;

	MainLoop(() {

		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		//renderer.Draw();
		box.Draw();

		
		fpsCounter.Update();
		window.glfwSetWindowTitle(("FPS:[" ~ to!string(fpsCounter.GetFPS) ~ "]").toStringz);
		CurrentCamera.KeyMove();
	});
	return true;
}

auto InitGLFW(in int window_width, in int window_height) {

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
