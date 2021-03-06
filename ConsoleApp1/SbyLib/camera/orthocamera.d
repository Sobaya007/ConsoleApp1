module sbylib.camera.orthocamera;

import sbylib;

final class OrthoCamera : Camera {
private:
	float width, height;
public:

	this(float width, float height, float nearZ, float farZ) {
		this.width = width;
		this.height = height;
		this.nearZ = nearZ;
		this.farZ = farZ;
	}

	mixin CreateSetterGetter!(width, "projUpdate = true;", "");
	mixin CreateSetterGetter!(height, "projUpdate = true;", "");

	override mat4 GenerateProjectionMatrix() {
		return mat4.Ortho(width, height, nearZ, farZ);
	}

	override Ray GetCameraRay(vec2 windowPos) {
		return new Ray(GetPos, GetVecZ);
	}
	
}