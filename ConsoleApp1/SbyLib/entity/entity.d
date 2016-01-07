module sbylib.core.entity.entity;

import sbylib.imports;

abstract class Entity {
protected:
	vec3 pos = vec3(0,0,0);
	vec3[3] base = [
		vec3(1,0,0),
		vec3(0,1,0),
		vec3(0,0,1)
	];
public:
	@property {
		void Pos(vec3 p) {
			pos = p;
		}

		void VecX(vec3 v) {
			base[0] = v;
		}

		void VecY(vec3 v) {
			base[1] = v;
		}

		void VecZ(vec3 v) {
			base[2] = v;
		}
	}

	vec3 GetPos() {
		return pos;
	}

	vec3 GetVecX() {
		return base[0];
	}

	vec3 GetVecY() {
		return base[1];
	}

	vec3 GetVecZ() {
		return base[2];
	}
}