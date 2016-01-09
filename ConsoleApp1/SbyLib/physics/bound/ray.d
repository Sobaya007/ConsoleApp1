module sbylib.physics.bound.ray;

import sbylib;

class Ray : Bound {
	vec3 vector;

	this(vec3 pos, vec3 vector) {
		Pos = pos;
		this.vector = vector;
	}

	vec3 GetNearestPoint(vec3 p) {
		float t = max(0, dot(p-GetPos, vector));
		return GetPos + vector * t;
	}

	float GetDistance(vec3 p) {
		vec3 d = p - GetPos;
		float t = max(0, dot(d, vector));
		return length(vector * t - d);
	}
}