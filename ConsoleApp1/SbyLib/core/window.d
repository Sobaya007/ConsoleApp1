module sbylib.core.window;

import sbylib;

enum MouseButton{BUTTON1, BUTTON2, BUTTON3}

mixin({ //========================================= enum KeyButton　の宣言
	string s = "enum KeyButton{";

	//アルファベット
	foreach (char c; 'A'..'Z'+1) {
		s ~= c;
		s ~= " = GLFW_KEY_" ~ c ~ ",";
	}
	//数字
	foreach (int i; 0..10) {
		s ~= "KEY_";
		s ~= to!string(i);
		s ~= " = GLFW_KEY_" ~ to!string(i) ~  ",";
	}
	//その他
	s ~= "Left = GLFW_KEY_LEFT,";
	s ~= "Right = GLFW_KEY_RIGHT,";
	s ~= "Up = GLFW_KEY_UP,";
	s ~= "Down = GLFW_KEY_DOWN,";
	s ~= "Space = GLFW_KEY_SPACE,";
	s ~= "Enter = GLFW_KEY_ENTER,";
	s ~= "Escape = GLFW_KEY_ESCAPE";

	s ~= "}";
	return s;
}());

class Window {
package:
	GLFWwindow *window;
public:
	this(GLFWwindow *window) {
		this.window = window;
	}

	bool isMousePressed(MouseButton mb) {
		final switch (mb) {
			mixin({
				string s;
				foreach (i; 0..3) {
					s ~= "case MouseButton.BUTTON" ~ to!string(i+1) ~ ":";
					s ~= "return glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_" ~ to!string(i+1) ~ ") == GLFW_PRESS;";
				}
				return s;
			}());
		}
		return false;
	}

	bool isKeyPressed(KeyButton kb) {
		return glfwGetKey(window, kb) != 0;
	}

	vec2 getMousePos() {
		double mousePosX, mousePosY;
		glfwGetCursorPos(window, &mousePosX, &mousePosY);
		return vec2(mousePosX, mousePosY);
	}

	@property int Width() {
		int w, h;
		glfwGetWindowSize(window, &w, &h);
		return w;
	}

	@property int Height() {
		int w, h;
		glfwGetWindowSize(window, &w, &h);
		return h;
	}

	@property int ViewportLeft() {
		int[4] data;
		glGetIntegerv(GL_VIEWPORT, data.ptr);
		return data[0];
	}

	@property int ViewportTop() {
		int[4] data;
		glGetIntegerv(GL_VIEWPORT, data.ptr);
		return data[1];
	}

	@property int ViewportWidth() {
		int[4] data;
		glGetIntegerv(GL_VIEWPORT, data.ptr);
		return data[2];
	}

	@property int ViewportHeight() {
		int[4] data;
		glGetIntegerv(GL_VIEWPORT, data.ptr);
		return data[3];
	}

}