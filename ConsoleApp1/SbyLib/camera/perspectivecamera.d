module sbylib.camera.perspectivecamera;

import sbylib;

final class PerspectiveCamera : Camera {
private:
	float aspectWperH;
	float fovy;
public:

	this(float aspect, float fovy, float nearZ, float farZ) {
		this.aspectWperH = aspect;
		this.fovy = fovy;
		this.nearZ = nearZ;
		this.farZ = farZ;
	}

	mixin CreateSetterGetter!(aspectWperH, "projUpdate = true;", "");
	mixin CreateSetterGetter!(fovy, "projUpdate = true;", "");

	override mat4 GenerateProjectionMatrix() {
		return mat4.Perspective(aspectWperH, fovy, nearZ, farZ);
	}

	override Ray GetCameraRay(vec2 windowPos) {

		auto tan = tan(fovy/2);
		auto vector = vec3(windowPos / vec2(CurrentWindow.ViewportWidth, CurrentWindow.ViewportHeight) - 0.5, 1);
		vector.y *= -1;
		vector.x *= 2 * aspectWperH * tan;
		vector.y *= 2 * tan;
		vector = (mat4.Invert(GetViewMatrix) * vec4(vector, 0) ).xyz;
		return new Ray(GetPos, vector);
	}
	
}