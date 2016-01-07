module sbylib.core.manipulator.simplerotator;

import sbylib.imports;

class SimpleRotator : Manipulator {

	this(Entity entity) {
		super(entity);
	}

	override void Manipulate() {
		with(entity) {
			if (CurrentWindow.isKeyPressed(KeyButton.W)) {
				Pos = GetPos + 0.2 * GetVecZ;
			} else if (CurrentWindow.isKeyPressed(KeyButton.S)) {
				Pos = GetPos - 0.2 * GetVecZ;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Left)) {
				mat4 mat = mat4.RotAxisAngle(GetVecY, 0.6);
				Pos = (mat * vec4(GetPos, 1.0f)).xyz;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Right)) {
				mat4 mat = mat4.RotAxisAngle(GetVecY, -0.6);
				Pos = (mat * vec4(GetPos, 1.0f)).xyz;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Up)) {
				mat4 mat = mat4.RotAxisAngle(GetVecX, 0.6);
				Pos = (mat * vec4(GetPos, 1.0f)).xyz;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Down)) {
				mat4 mat = mat4.RotAxisAngle(GetVecX, -0.6);
				Pos = (mat * vec4(GetPos, 1.0f)).xyz;
			}
			VecZ = -normalize(GetPos);
			if (CurrentWindow.isKeyPressed(KeyButton.Up) || CurrentWindow.isKeyPressed(KeyButton.Down)) {
				VecY = normalize(cross(GetVecZ, GetVecX));
			}

			static vec2 beforeMousePos;
			vec2 mousePos = CurrentWindow.getMousePos();
			if (CurrentWindow.isMousePressed(MouseButton.BUTTON1)) {
				const float delta = 0.005;
				auto mat = mat4.RotFromTo(GetVecZ, normalize(GetVecZ
														  + GetVecX * (delta * (mousePos.x - beforeMousePos.x))
														  - GetVecY * (delta * (mousePos.y - beforeMousePos.y))));
				Pos = (mat * vec4(GetPos, 1)).xyz;
				VecY = (mat * vec4(GetVecY, 1)).xyz;
				VecZ = (mat * vec4(GetVecZ, 1)).xyz;
			}
			VecX = normalize(cross(GetVecY, GetVecZ));
			beforeMousePos = mousePos;
		}
	}
}