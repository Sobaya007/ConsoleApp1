module sbylib.physics.bound.basebound;

import sbylib.imports;

abstract class Bound : Entity {
private:
	static CollisionInfo CollisionDetection(Bound b1, Bound b2) {
		if ( is(b1 : plane) ) {
			if ( is(b2 : plane) ) {
				return ColPlaneAndPlane(cast(PlaneBound)b1, cast(PlaneBound)b2);
			} else if (is (b2 : OBB) ) {
				return ColPlaneAndOBB(cast(PlaneBound)b1, cast(OBB)b2);
			}
		} else if ( is(b1 : OBB) ) {
			if ( is(b2 : plane) ) {
				return ColPlaneAndOBB(cast(PlaneBound)b2, cast(OBB)b1);
			} else if (is (b2 : OBB) ) {
				return ColOBBAndOBB(cast(OBB)b1, cast(OBB)b2);
			}
		}
		throw new Exception("Error type collision");
	}

	static CollisionInfo ColPlaneAndPlane(PlaneBound p1, PlaneBound p2) {
		CollisionInfo result;
		if ( abs( dot(p1.normal, p2.normal) ) == 1) { //=================平行
			if ( dot(p1.pos - p2.pos, p1.normal) == 0) { //========同一
				result.isHit = true;
			} else { //==================================================非同一
				result.isHit = false;
			}
		} else { //======================================================平行でない
			result.isHit = true;
		}
		return result;
	}

	static CollisionInfo ColPlaneAndOBB(PlaneBound p, OBB o) {
		CollisionInfo result;
		float d = 0;
		foreach (v; o.GetVertices) {
			float d2 = dot (p.normal, v - p.pos);
			if (d2 * d < 0) {//==========================================OBBのある２頂点が平面を挟む
				result.isHit = true;
				return result;
			}
			d = d2;
		}
		result.isHit = false;
		return result;
	}
	
	static CollisionInfo ColOBBAndOBB(OBB o1, OBB o2) {
		CollisionInfo result;

		auto getAxis = (int index){
			if (index < 3) return o1.base[index];
			else if (index < 6) return o2.base[index];
			else return normalize( cross( o1.base[(index-6)/3], o2.base[(index-6)%3]) );
		};

		foreach (i; 0..15) {
			auto axis = getAxis(i);
			float d1 = 
				+ abs( dot(axis, o1.base[0]) * o1.r[0])
				+ abs( dot(axis, o1.base[1]) * o1.r[1])
				+ abs( dot(o1.base[i], o1.base[2]) * o1.r[2]);
			float d2 = 
				+ abs( dot(axis, o2.base[0]) * o2.r[0])
				+ abs( dot(o1.base[i], o2.base[1]) * o2.r[1])
				+ abs( dot(o1.base[i], o2.base[2]) * o2.r[2]);
			float d3 =
				abs( dot(axis, o2.pos - o1.pos));
			if (d1 + d2 >= d3) {//=======================================ヒット
				result.isHit = true;
				return result;
			}
		}

		return result;
	}
}