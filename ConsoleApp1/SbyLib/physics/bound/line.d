module sbylib.physics.bound.line;

import sbylib;

class LineBounds : Bound {

	vec3 vector;

	this(vec3 pos, vec3 vector) {
		Pos = pos;
		this.vector = vector;
	}

	float Distance(vec3 p) {
		vec3 d = p - GetPos;
		return length(vector * dot(d, vector) - d);
	}
}