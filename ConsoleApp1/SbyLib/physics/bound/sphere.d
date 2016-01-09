module sbylib.physics.bound.sphere;

import sbylib;

class BoundingSphere : Bound {

	float radius;

	this(vec3 pos, float radius) {
		Pos = pos;
		this.radius = radius;
	}
}