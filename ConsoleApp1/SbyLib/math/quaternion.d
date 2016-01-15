module sbylib.math.quaternion;

import sbylib;


/*Note:
q x ~q
*/

struct Quaternion(T) if (__traits(isArithmetic, T)) {

	T x, y, z, w;

	this(T x, T y, T z, T w) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	this(Vector!(T,3) v, T w) {
		this(v.x,v.y,v.z,w);
	}

	Quaternion!T opUnary(string op)() const {
		static if (op == "+") {
			return this;
		} else static if (op == "-") {
			return Quaternion!T(-x,-y,-z,-w);
		} else static if (op == "~") {
			return Quaternion!T(-x,-y,-z,+w);
		} else {
			static assert(false);
		}
	}

	ref T opIndex(uint i) {
		switch (i) {
			case 0: return x;
			case 1: return y;
			case 2: return z;
			case 3: return w;
			default: assert(false);
		}
	}

	Quaternion!T opBinary(string op)(Quaternion!T q) const {
		Quaternion!T result;
		static if (op == "+" || op == "-") {
			mixin({
				return "
					result.x = x " ~ op ~ " q.x;
					result.y = y " ~ op ~ " q.y;
					result.z = z " ~ op ~ " q.z;
					result.w = w " ~ op ~ " q.w;
					return result;
					";
			}());
		} else static if (op == "*") {
			result.w = w * q.w - x * q.x - y * q.y - z * q.z;
			result.x = w * q.x + x * q.w + y * q.z - z * q.y;
			result.y = w * q.y - x * q.z + y * q.w + z * q.x;
			result.z = w * q.z + x * q.y - y * q.x + z * q.w;
			return result;
		}
	}

	Quaternion!T opBinary(string op)(T t) {
		static if (op == "+" || op == "-" || op == "*" || op == "/") {
			Quaternion!T result;
			mixin({
				return "
					result.x = x " ~ op ~ " t;
					result.y = y " ~ op ~ " t;
					result.z = z " ~ op ~ " t;
					result.w = w " ~ op ~ " t;
					return result;
					";
			}());
		} else {
			static assert(false);
		}
	}

	void opOpAssign(string op)(Quaternion!T q) {
		static if (op == "+" || op == "-") {
			mixin({
				return "
					this.x = x " ~ op ~ " q.x;
					this.y = y " ~ op ~ " q.y;
					this.z = z " ~ op ~ " q.z;
					this.w = w " ~ op ~ " q.w;";
			}());
		} else static if (op == "*") {
			Quaternion result;
			result.w = w * q.w - x * q.x - y * q.y - z * q.z;
			result.x = w * q.x + x * q.w + y * q.z - z * q.y;
			result.y = w * q.y - x * q.z + y * q.w + z * q.x;
			result.z = w * q.z + x * q.y - y * q.x + z * q.w;
			this.x = result.x;
			this.y = result.y;
			this.z = result.z;
			this.w = result.w;
		} else {
			static assert(false);
		}
	}

	void opOpAssign(string op)(T t) {
		static if (op == "+" || op == "-" || op == "*" || op == "/") {
			mixin({
				return "
					this.x = x " ~ op ~ " t;
					this.y = y " ~ op ~ " t;
					this.z = z " ~ op ~ " t;
					this.w = w " ~ op ~ " t;
					";
			}());
		} else {
			static assert(false);
		}
	}

	@property {
		Vector!(T,3) Axis() {
			Vector!(T,3) result;
			result.x = x;
			result.y = y;
			result.z = z;
			return result;
		}

		void Axis(Vector!(T,3) axis) {
			this.x = axis.x;
			this.y = axis.y;
			this.z = axis.z;
		}
	}

	static Quaternion!T CreateAxisAngle(Vector!(T,3) axis, T angle) {
		Quaternion!T result;
		float s = sin(angle/2);
		result.x = axis.x * s;
		result.y = axis.y * s;
		result.z = axis.z * s;
		result.w = cos(angle/2);
		return result;
	}
}

T length(T)(Quaternion!T q) {
	mixin({
		string code = "T result = sqrt(";
		foreach (i; 0..4) {
			code ~= "+q[" ~ to!string(i) ~ "] * q[" ~ to!string(i) ~ "]";
		}
		code ~= ");";
		return code;
	}());
	return result;
}

Quaternion!T normalize(T)(Quaternion!T q) {
	return q / length(q);
}

alias Quaternion!float quat;