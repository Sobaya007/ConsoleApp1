module sbylib.camera.manipulator;
import sbylib.imports;

class SbyCameraManipulator {

	abstract void Manipulate(Camera camera);

	uint LeftKey = GLFW_KEY_W;

}

class CameraSimpleRotator : SbyCameraManipulator {

	override void Manipulate(Camera camera) {
		with(camera) {
			if (glfwGetKey(CurrentWindow, GLFW_KEY_W)) {
				Eye = Eye + 0.2 * Vec;
			} else if (glfwGetKey(CurrentWindow, GLFW_KEY_S)) {
				Eye = Eye - 0.2 * Vec;
			} else if (glfwGetKey(CurrentWindow, GLFW_KEY_LEFT)) {
				mat4 mat = mat4.RotAxisAngle(Up, 0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			} else if (glfwGetKey(CurrentWindow, GLFW_KEY_RIGHT)) {
				mat4 mat = mat4.RotAxisAngle(Up, -0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			} else if (glfwGetKey(CurrentWindow, GLFW_KEY_UP)) {
				mat4 mat = mat4.RotAxisAngle(XVec, 0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			} else if (glfwGetKey(CurrentWindow, GLFW_KEY_DOWN)) {
				mat4 mat = mat4.RotAxisAngle(XVec, -0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			}
			Target = vec3(0, 0, 0);
			if (glfwGetKey(CurrentWindow, GLFW_KEY_UP) || glfwGetKey(CurrentWindow, GLFW_KEY_DOWN)) {
				Up = normalize(cross(Vec, XVec));
			}

			static double bmx, bmy;
			double mx, my;
			glfwGetCursorPos(CurrentWindow, &mx, &my);
			if (glfwGetMouseButton(CurrentWindow, GLFW_MOUSE_BUTTON_1)) {
				const float delta = 0.005;
				auto mat = mat4.RotFromTo(ZVec, normalize(ZVec
														  - XVec * (delta * (mx-bmx))
														  + YVec * (delta * (my-bmy))));
				Eye = (mat * vec4(Eye.x, Eye.y, Eye.z, 1)).xyz;
				Up = (mat * vec4(Up.x, Up.y, Up.z, 1)).xyz;
				Vec = (mat * vec4(Vec.x, Vec.y, Vec.z, 1)).xyz;
			}
			bmx = mx; bmy = my;
		}
	}
};