module sbylib.primitive.primitive;

import sbylib;

abstract class Primitive : EntityDrawable {

	private mat4 matWorld = mat4.Identity;
	private bool matWorldUpdateFlag = false;
	private mat4 mat = mat4.Identity;
	private bool matUpdateFlag = false;
	private mat4 matAll = mat4.Identity;

	void opOpAssign(string op)(vec3 v) {
		static if (op == "*") {
			mat *= mat4.Scale(v);
			matUpdateFlag = true;
		} else if (op == "+") {
			Pos = GetPos + v;
		}
	}

	void opOpAssign(string op)(mat4 m) {
		static if (op == "*") {
			mat *= m;
			matUpdateFlag = true;
		}
	}

	mat4 GetWorldMatrix() {
		if (matWorldUpdateFlag) {
			matWorld = mat4.Translation(pos) * mat4.Replacement(GetVecX, GetVecY, GetVecZ);
		}
		if (matUpdateFlag || matWorldUpdateFlag) {
			matWorldUpdateFlag = false;
			matUpdateFlag = false;
			matAll = matWorld * mat;
		}
		return matAll;
	}

	@property {

		override {
			void Pos(vec3 p) {
				pos = p;
				matWorldUpdateFlag = true;
			}

			void VecX(vec3 v) {
				base[0] = v;
				matWorldUpdateFlag = true;
			}

			void VecY(vec3 v) {
				base[1] = v;
				matWorldUpdateFlag = true;
			}

			void VecZ(vec3 v) {
				base[2] = v;
				matWorldUpdateFlag = true;
			}
		}
	}
}