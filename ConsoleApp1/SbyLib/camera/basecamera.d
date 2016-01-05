module sbylib.camera.basecamera;

import sbylib.imports;

abstract class Camera : Entity {

protected:
	vec3 eye = vec3(0, 0, -1);
	vec3 vec = vec3(0, 0, 1);
	vec3 up = vec3(0, 1, 0);
	bool viewUpdate = true;
	mat4 viewMatrix;
	protected bool projUpdate = true;
	mat4 projMatrix;
	bool[3] baseVecUpdate = true;
	vec3[3] baseVec;
	bool viewProjUpdate;
	mat4 viewProjMatrix;
	float nearZ, farZ;

public:

	Manipulator manip;

	this() {
		manip = new SimpleRotator;
	}

	mixin  CreateSetterGetter!(eye,
							   "baseVecUpdate[0] = baseVecUpdate[2] = true;
							   viewUpdate = true;
							   viewProjUpdate = true;", "");

	mixin CreateSetterGetter!(vec,
							  "baseVecUpdate[0] = baseVecUpdate[2] = true;
							  viewUpdate = true;
							  viewProjUpdate = true;", "");

	mixin CreateSetterGetter!(up,
							  "baseVecUpdate[1] = true;
							  viewUpdate = true;
							  viewProjUpdate = true;", "");

	mixin CreateSetterGetter!(nearZ, "projUpdate = true;", "");
	mixin CreateSetterGetter!(farZ, "projUpdate = true;", "");

	@property {
		void Target(vec3 t) {
			vec = normalize(t - eye);
			baseVecUpdate[0] = baseVecUpdate[2] = true;
			viewUpdate = true;
			viewProjUpdate = true;
		}
		vec3 XVec() {
			if (baseVecUpdate[0]) {
				baseVecUpdate[0] = false;
				baseVec[0] = normalize(cross(up, vec));
			}
			return baseVec[0];
		}
		vec3 YVec() {
			if (baseVecUpdate[1]) {
				baseVecUpdate[1] = false;
				baseVec[1] = normalize(up);
			}
			return baseVec[1];
		}
		vec3 ZVec() {
			if (baseVecUpdate[2]) {
				baseVecUpdate[2] = false;
				baseVec[2] = normalize(vec);
			}
			return baseVec[2];
		}
	}

	mat4 GetViewMatrix() {
		if (viewUpdate) {
			viewUpdate = false;
			viewMatrix = mat4.LookAt(eye, vec, up);
		}
		return viewMatrix;
	}

	mat4 GetProjectionMatrix() {
		if (projUpdate) {
			projUpdate = false;
			projMatrix = GenerateProjectionMatrix();
		}
		return projMatrix;
	}

	mat4 GetViewProjectionMatrix() {
		if (viewProjUpdate) {
			viewProjUpdate = false;
			viewProjMatrix = GetProjectionMatrix() * GetViewMatrix();
		}
		return viewProjMatrix;
	}

	mat4 GetBillboardMatrix() {
		import std.math;
		auto mat = mat4.LookAt(vec3(0,0,0), vec, up);
		return mat4.Invert(mat);
	}

	void KeyMove() {
		manip.Manipulate(this);
	}

	protected abstract mat4 GenerateProjectionMatrix();
}