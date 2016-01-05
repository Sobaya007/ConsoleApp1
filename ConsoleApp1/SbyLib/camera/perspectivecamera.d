module sbylib.camera.perspectivecamera;

import sbylib.imports;

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
}