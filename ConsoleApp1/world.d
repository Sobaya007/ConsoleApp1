module sbylib.world;

import sbylib.imports;
import std.datetime;
import core.thread;

package GLFWwindow *CurrentWindow;
private float fps;
Camera CurrentCamera;
long CurrentFrameTime; //milliseconds

void SbyInit(GLFWwindow *window, long frameTime) {
	CurrentWindow = window;
	CurrentFrameTime = frameTime;
}

void MainLoop(void delegate() stepAndDraw) {
	StopWatch sw;
	sw.start();
	while (!glfwWindowShouldClose(CurrentWindow))
	{
		stepAndDraw();
		//バッファを更新
		glfwSwapBuffers(CurrentWindow);
		//イベントをさばく
		glfwPollEvents();
		auto period = sw.peek().msecs();
		if (CurrentFrameTime > period)
			Thread.sleep(dur!("msecs")(CurrentFrameTime - period));
		sw.reset();
		stdout.flush();
	}
	//後始末
	glfwTerminate();
}