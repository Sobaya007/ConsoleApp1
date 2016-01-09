module sbylib.core.manipulator.simplerotator;

import sbylib;

class SimpleRotator : Manipulator {

	this(Entity entity) {
		super(entity);
	}

	Entity focus;

	protected vec3 beforeCenter = vec3(0,0,0);

	override void Manipulate() {
		vec3 center;
		if (focus) center = focus.GetPos;
		else center = vec3(0,0,0);
		with(entity) {
			Pos = GetPos + center - beforeCenter;
			if (CurrentWindow.isKeyPressed(KeyButton.W)) {
				Pos = GetPos + 0.2 * GetVecZ;
			} else if (CurrentWindow.isKeyPressed(KeyButton.S)) {
				Pos = GetPos - 0.2 * GetVecZ;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Left)) {
				mat4 mat = mat4.RotAxisAngle(GetVecY, 0.6);
				Pos = (mat * vec4(GetPos - center, 1.0f)).xyz + center;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Right)) {
				mat4 mat = mat4.RotAxisAngle(GetVecY, -0.6);
				Pos = (mat * vec4(GetPos - center, 1.0f)).xyz + center;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Up)) {
				mat4 mat = mat4.RotAxisAngle(GetVecX, 0.6);
				Pos = (mat * vec4(GetPos - center, 1.0f)).xyz + center;
			} else if (CurrentWindow.isKeyPressed(KeyButton.Down)) {
				mat4 mat = mat4.RotAxisAngle(GetVecX, -0.6);
				Pos = (mat * vec4(GetPos - center, 1.0f)).xyz + center;
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
				//VecY = (mat * vec4(GetVecY, 1)).xyz;
				VecZ = (mat * vec4(GetVecZ, 1)).xyz;
			}
			VecX = normalize(cross(GetVecY, GetVecZ));
			beforeMousePos = mousePos;
		}
		beforeCenter = center;


	}
}