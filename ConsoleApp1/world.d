module sbylib.core.world;

import sbylib;
import std.datetime;
import core.thread;

Window CurrentWindow;
private float fps;
Camera CurrentCamera;
long CurrentFrameTime; //milliseconds

void SbyInit(GLFWwindow *window, long frameTime) {
	CurrentWindow = new Window(window);
	CurrentFrameTime = frameTime;
}

void MainLoop(void delegate() stepAndDraw) {
	StopWatch sw;
	sw.start();
	while (!glfwWindowShouldClose(CurrentWindow.window))
	{
		stepAndDraw();
		//Manipulatorを動かす
		ManipulatorManager.MoveAll();
		//バッファを更新
		glfwSwapBuffers(CurrentWindow.window);
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