module sbylib.core.window;

import sbylib;

enum MouseButton{BUTTON1, BUTTON2, BUTTON3}

mixin({ //========================================= enum KeyButton　の宣言
	string s = "enum KeyButton{";

	//アルファベット
	foreach (char c; 'A'..'Z'+1) {
		s ~= c;
		s ~= ",";
	}
	//数字
	foreach (int i; 0..10) {
		s ~= "KEY_";
		s ~= to!string(i);
		s ~= ",";
	}
	//その他
	s ~= "Left,";
	s ~= "Right,";
	s ~= "Up,";
	s ~= "Down,";
	s ~= "Space,";
	s ~= "Enter";

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
		return glfwGetKey(window, keyCodeTable[kb]) != 0;
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

static uint[KeyButton] keyCodeTable;

static this() {
	mixin({
		string s;
		//アルファベット
		foreach (char c; 'A'..'Z'+1) {
			s ~= "keyCodeTable[KeyButton." ~ c ~ "] = GLFW_KEY_" ~ c ~ ";";
		}
		//数字
		foreach (i; 0..10) {
			s ~= "keyCodeTable[KeyButton.KEY_" ~ to!string(i) ~ "] = GLFW_KEY_" ~ to!string(i) ~ ";";
		}
		return s;
	}());
	//その他
	keyCodeTable[KeyButton.Left] = GLFW_KEY_LEFT;
	keyCodeTable[KeyButton.Right] = GLFW_KEY_RIGHT;
	keyCodeTable[KeyButton.Up] = GLFW_KEY_UP;
	keyCodeTable[KeyButton.Down] = GLFW_KEY_DOWN;
	keyCodeTable[KeyButton.Space] = GLFW_KEY_SPACE;
	keyCodeTable[KeyButton.Enter] = GLFW_KEY_ENTER;
}