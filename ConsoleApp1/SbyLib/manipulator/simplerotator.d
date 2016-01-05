module sbylib.manipulator.simplerotator;

import sbylib.imports;

class SimpleRotator : Manipulator {

	override void Manipulate(Entity entity) {
		Camera camera = cast(Camera)entity;
		with(camera) {
			if (CurrentWindow.isPressed(KeyButton.W)) {
				Eye = Eye + 0.2 * Vec;
			} else if (CurrentWindow.isPressed(KeyButton.S)) {
				Eye = Eye - 0.2 * Vec;
			} else if (CurrentWindow.isPressed(KeyButton.Left)) {
				mat4 mat = mat4.RotAxisAngle(Up, 0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			} else if (CurrentWindow.isPressed(KeyButton.Right)) {
				mat4 mat = mat4.RotAxisAngle(Up, -0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			} else if (CurrentWindow.isPressed(KeyButton.Up)) {
				mat4 mat = mat4.RotAxisAngle(XVec, 0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			} else if (CurrentWindow.isPressed(KeyButton.Down)) {
				mat4 mat = mat4.RotAxisAngle(XVec, -0.6);
				Eye = (mat * vec4(Eye, 1.0f)).xyz;
			}
			Target = vec3(0, 0, 0);
			if (CurrentWindow.isPressed(KeyButton.Up) || CurrentWindow.isPressed(KeyButton.Down)) {
				Up = normalize(cross(Vec, XVec));
			}

			static vec2 beforeMousePos;
			vec2 mousePos = CurrentWindow.getMousePos();
			if (CurrentWindow.isPressed(MouseButton.BUTTON1)) {
				const float delta = 0.005;
				auto mat = mat4.RotFromTo(ZVec, normalize(ZVec
														  + XVec * (delta * (mousePos.x - beforeMousePos.x))
														  - YVec * (delta * (mousePos.y - beforeMousePos.y))));
				Eye = (mat * vec4(Eye.x, Eye.y, Eye.z, 1)).xyz;
				Up = (mat * vec4(Up.x, Up.y, Up.z, 1)).xyz;
				Vec = (mat * vec4(Vec.x, Vec.y, Vec.z, 1)).xyz;
			}
			beforeMousePos = mousePos;
		}
	}
}