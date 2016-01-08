module sbylib.camera.camera;

import sbylib;

abstract class Camera : Entity {

protected:
	bool viewUpdate = true;
	mat4 viewMatrix;
	protected bool projUpdate = true;
	mat4 projMatrix;
	bool[3] baseUpdate = true;
	bool viewProjUpdate;
	mat4 viewProjMatrix;
	float nearZ, farZ;

public:

	this() {
		pos = vec3(0,0,-1);
		VecX = vec3(-1,0,0);
	}

	mixin CreateSetterGetter!(nearZ, "projUpdate = true;", "");
	mixin CreateSetterGetter!(farZ, "projUpdate = true;", "");

	@property {
		override {
			void Pos(vec3 p) {
				super.Pos(p);
				baseUpdate[0] = baseUpdate[2] = true;
				viewUpdate = true;
				viewProjUpdate = true;
			}

			vec3 GetVecX() {
				if (baseUpdate[0]) {
					baseUpdate[0] = false;
					base[0] = normalize(base[0]);
				}
				return base[0];
			}

			void VecX(vec3 v) {
				super.VecX(v);
				baseUpdate[0] = true;
				viewUpdate = true;
				viewProjUpdate = true;
			}
			vec3 GetVecY() {
				if (baseUpdate[1]) {
					baseUpdate[1] = false;
					base[1] = normalize(base[1]);
				}
				return base[1];
			}
			void VecY(vec3 v) {
				super.VecY(v);
				baseUpdate[1] = true;
				viewUpdate = true;
				viewProjUpdate = true;
			}
			vec3 GetVecZ() {
				if (baseUpdate[2]) {
					baseUpdate[2] = false;
					base[2] = normalize(base[2]);
				}
				return base[2];
			}
			void VecZ(vec3 v) {
				super.VecZ(v);
				baseUpdate[2] = true;
				viewUpdate = true;
				viewProjUpdate = true;
			}
		}

		void Target(vec3 t) {
			VecZ(normalize(t - GetPos));
		}
	}

	mat4 GetViewMatrix() {
		if (viewUpdate) {
			viewUpdate = false;
			viewMatrix = mat4.LookAt(GetPos, GetVecZ, GetVecY);
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
		auto mat = mat4.LookAt(vec3(0,0,0), GetVecZ, GetVecY);
		return mat4.Invert(mat);
	}

	protected abstract mat4 GenerateProjectionMatrix();
}