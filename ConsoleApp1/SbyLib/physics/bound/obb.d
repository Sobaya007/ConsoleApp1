module sbylib.physics.bound.obb;

import sbylib;

class OBB : Bound {

	float[3] r;

	vec3[] GetVertices() {
		return [
			mixin({
				string s;
				foreach (i; 0..3) {
					s ~= "pos + r[" ~ to!string(i) ~ "] * base[" ~ to!string(i) ~ "],";
					s ~= "pos - r[" ~ to!string(i) ~ "] * base[" ~ to!string(i) ~ "],";
				}
				return s[0..$-1];
			}())
		];
	}
}