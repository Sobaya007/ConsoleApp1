module sbylib.primitive.baseprimitive;

import sbylib.imports;

abstract class Primitive {
	public abstract void Draw();

	mat4 mat = mat4.Identity;

	void opOpAssign(string op)(vec3 v) {
		static if (op == "*") {
			mat = mat * mat4.Scale(v);
		}
	}
}