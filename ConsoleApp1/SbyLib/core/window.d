module sbylib.core.window;

import sbylib.imports;

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

	bool isPressed(MouseButton mb) {
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

	bool isPressed(KeyButton kb) {
		return glfwGetKey(window, keyCodeTable[kb]) != 0;
	}

	vec2 getMousePos() {
		double mousePosX, mousePosY;
		glfwGetCursorPos(window, &mousePosX, &mousePosY);
		return vec2(mousePosX, mousePosY);
	}

}

static uint[KeyButton] keyCodeTable;

static this() {
	mixin({
		string s;
		//アルファベット
		foreach (char c; 'A'..'Z') {
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
}