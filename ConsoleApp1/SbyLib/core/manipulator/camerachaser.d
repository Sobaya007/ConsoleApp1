module sbylib.core.manipulator.camerachaser;
import sbylib;

class CameraChaser : Manipulator {

	this(Camera camera) {
		super(camera);
		this.camera = camera;
	}

	Entity focus;
	Camera camera;

	protected vec3 beforeCenter = vec3(0,0,0);

	override void Manipulate() {
		vec3 center;
		if (focus) center = focus.GetPos;
		else center = vec3(0,0,0);
		with(camera) {
			Pos = GetPos + center - beforeCenter;
			if (CurrentWindow.isKeyPressed(KeyButton.Up) || CurrentWindow.isKeyPressed(KeyButton.Down)) {
				VecY = normalize(cross(GetVecZ, GetVecX));
			}
			const float speed = 0.3;
			vec3 vec = GetPos - center;
			float len = length(vec);
			if (CurrentWindow.isKeyPressed(KeyButton.W)) {
				if (len > speed) Pos = center + normalize(vec) * (len - speed);
			}
			if (CurrentWindow.isKeyPressed(KeyButton.S)) {
				Pos = center + normalize(vec) * (len + speed);
			}

			static vec2 beforeMousePos;
			vec2 mousePos = CurrentWindow.getMousePos();
			if (CurrentWindow.isMousePressed(MouseButton.BUTTON1)) {
				const float delta = 0.005;
				auto mat = mat4.Translation(center) * mat4.RotFromTo(GetVecZ, normalize(GetVecZ
															 + GetVecX * (delta * (mousePos.x - beforeMousePos.x))
															 - GetVecY * (delta * (mousePos.y - beforeMousePos.y)))) * mat4.Translation(-center);
				Pos = (mat * vec4(GetPos, 1)).xyz;
				VecZ = (mat * vec4(GetVecZ, 1)).xyz;
			}
			VecZ = normalize(center - GetPos);
			VecX = normalize(cross(GetVecY, GetVecZ));
			beforeMousePos = mousePos;
		}
		beforeCenter = center;
	}
}