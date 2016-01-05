module sbylib.primitive.baseprimitive;

import sbylib.imports;

abstract class Primitive : Entity {
	public abstract void Draw();

	public mat4 mat = mat4.Identity;

	void opOpAssign(string op)(vec3 v) {
		static if (op == "+") {
			mat = mat * mat4.Translation(v);
		} else if (op == "-") {
			mat = mat * mat4.Translation(-v);
		} else if (op == "*") {
			mat = mat * mat4.Scale(v);
		} else if (op == "/") {
			mat = mat * mat4.Scale(vec3(1.0f / v.x, 1.0f / v.y, 1.0f / v.z));
		}
	}
}

