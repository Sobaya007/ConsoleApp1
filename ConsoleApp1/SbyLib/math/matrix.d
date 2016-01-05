module sbylib.math.matrix;

import sbylib.math.imports;
import std.conv;
import std.math;
import std.string;
import std.stdio;

//U型の4x4行列
struct Matrix(U) {
private:
	U[16] arrayForConvert; 
public:
	U[4][4] elements;

	Matrix opBinary(string op)(Matrix m) {
		Matrix result;
		static if (op == "+" || op == "-") {
			mixin(getOpBinaryMMCode(op));
			return result;
		} else if (op == "*") {
			mixin(multMMCode());
			return result;
		}
		assert(false);
	}

	Matrix opBinary(string op)(U s) {
		Matrix result;
		static if (op == "*" || op == "/") {
			mixin(getOpBinaryMSCode(op));
			return result;
		}
		assert(false);
	}

	vec4 opBinary(string op)(Vector!(U,4) v) {
		vec4 result;
		static if (op == "*") {
			mixin(multMVCode());
			return result;
		}
		assert(false);
	}

	void opOpAssign(string op)(Vector!(U,4) v) {
		static if (op == "*") {
			mixin(multMVAssignCode());
			return result;
		}
		assert(false);
	}

	void opOpAssign(string op)(Matrix m) {
		static if (op == "+" || op == "-") {
			mixin(getOpAssignMMCode(op));
			return;
		} else if (op == "*") {
			Matrix result = this * m;
			mixin(getCopyCode("result"));
			return;
		}
		assert(false);
	}

	static Matrix Identity() {
		Matrix result;
		mixin(getIdentityCode());
		return result;
	}

	static auto Translation(int T)(Vector!(U, T) vec) if (T == 3 || T == 4) {
		Matrix result;
		mixin(getTranslationCode());
		return result;
	}

	static Matrix Scale(int T)(Vector!(U, T) vec) if (T == 3 || T == 4) {
		Matrix result;
		mixin(getScaleCode());
		return result;
	}

	static Matrix RotAxisAngle(Vector!(U,3) v, U angle) {
		U rad = ToRad(angle);
		auto c = cos(rad);
		auto s = sin(rad);
		Matrix result;
		mixin(getRotAxisCode());
		return result;
	}

	static Matrix RotFromTo(Vector!(U,3) from, Vector!(U,3) to) {
		auto v = cross(from, to);
		auto s = v.length;
		if (s == 0) return Identity();
		auto rad = asin(v.length);
		auto c = cos(rad);
		v = normalize(v);
		Matrix result;
		mixin(getRotAxisCode());
		return result;
	}

	static Matrix LookAt(Vector!(U,3) eye, Vector!(U,3) vec, Vector!(U,3) up) {
		Matrix result;
		mixin(getLookAtCode());
		return result;
	}

	static Matrix Ortho(U width, U height, U nearZ, U farZ) {
		Matrix result;
		mixin(getOrthoCode());
		return result;
	}

	static Matrix Perspective(U aspectWperH, U fovy, U nearZ, U farZ) {
		Matrix result;
		mixin(getPerspectiveCode());
		return result;
	}

	static Matrix Invert(Matrix m) {
		auto e2233_2332 = m.elements[2][2] * m.elements[3][3] - m.elements[2][3] * m.elements[3][2];
		auto e2133_2331 = m.elements[2][1] * m.elements[3][3] - m.elements[2][3] * m.elements[3][1];
		auto e2132_2231 = m.elements[2][1] * m.elements[3][2] - m.elements[2][2] * m.elements[3][1];
		auto e1233_1332 = m.elements[1][2] * m.elements[3][3] - m.elements[1][3] * m.elements[3][2];
		auto e1133_1331 = m.elements[1][1] * m.elements[3][3] - m.elements[1][3] * m.elements[3][1];
		auto e1132_1231 = m.elements[1][1] * m.elements[3][2] - m.elements[1][2] * m.elements[3][1];
		auto e1322_1223 = m.elements[1][3] * m.elements[2][2] - m.elements[1][2] * m.elements[2][3];
		auto e1123_1321 = m.elements[1][1] * m.elements[2][3] - m.elements[1][3] * m.elements[2][1];
		auto e1122_1221 = m.elements[1][1] * m.elements[2][2] - m.elements[1][2] * m.elements[2][1];
		auto e2033_2330 = m.elements[2][0] * m.elements[3][3] - m.elements[2][3] * m.elements[3][0];
		auto e2032_2230 = m.elements[2][0] * m.elements[3][2] - m.elements[2][2] * m.elements[3][0];
		auto e1033_1330 = m.elements[1][0] * m.elements[3][3] - m.elements[1][3] * m.elements[3][0];
		auto e1032_1230 = m.elements[1][0] * m.elements[3][2] - m.elements[1][2] * m.elements[3][0];
		auto e1023_1320 = m.elements[1][0] * m.elements[2][3] - m.elements[1][3] * m.elements[2][0];
		auto e1022_1220 = m.elements[1][0] * m.elements[2][2] - m.elements[1][2] * m.elements[2][0];
		auto e2031_2130 = m.elements[2][0] * m.elements[3][1] - m.elements[2][1] * m.elements[3][0];
		auto e1031_1130 = m.elements[1][0] * m.elements[3][1] - m.elements[1][1] * m.elements[3][0];
		auto e1021_1120 = m.elements[1][0] * m.elements[2][1] - m.elements[1][1] * m.elements[2][0];
		auto det =
			m.elements[0][0] * (m.elements[1][1] * e2233_2332 - m.elements[1][2] * e2133_2331 + m.elements[1][3] * e2132_2231) -
			m.elements[0][1] * (m.elements[1][0] * e2233_2332 - m.elements[1][2] * e2033_2330 + m.elements[1][3] * e2032_2230) +
			m.elements[0][2] * (m.elements[1][0] * e2133_2331 - m.elements[1][1] * e2033_2330 + m.elements[1][3] * e2031_2130) -
			m.elements[0][3] * (m.elements[1][0] * e2132_2231 - m.elements[1][1] * e2032_2230 + m.elements[1][2] * e2031_2130)
			;
		if (det != 0) det = 1 / det;
		auto t00 =  m.elements[1][1] * e2233_2332 - m.elements[1][2] * e2133_2331 + m.elements[1][3] * e2132_2231;
		auto t01 = -m.elements[0][1] * e2233_2332 + m.elements[0][2] * e2133_2331 - m.elements[0][3] * e2132_2231;
		auto t02 =  m.elements[0][1] * e1233_1332 - m.elements[0][2] * e1133_1331 + m.elements[0][3] * e1132_1231;
		auto t03 =  m.elements[0][1] * e1322_1223 + m.elements[0][2] * e1123_1321 - m.elements[0][3] * e1122_1221;
		auto t10 = -m.elements[1][0] * e2233_2332 + m.elements[1][2] * e2033_2330 - m.elements[1][3] * e2032_2230;
		auto t11 =  m.elements[0][0] * e2233_2332 - m.elements[0][2] * e2033_2330 + m.elements[0][3] * e2032_2230;
		auto t12 = -m.elements[0][0] * e1233_1332 + m.elements[0][2] * e1033_1330 - m.elements[0][3] * e1032_1230;
		auto t13 = -m.elements[0][0] * e1322_1223 - m.elements[0][2] * e1023_1320 + m.elements[0][3] * e1022_1220;
		auto t20 =  m.elements[1][0] * e2133_2331 - m.elements[1][1] * e2033_2330 + m.elements[1][3] * e2031_2130;
		auto t21 = -m.elements[0][0] * e2133_2331 + m.elements[0][1] * e2033_2330 - m.elements[0][3] * e2031_2130;
		auto t22 =  m.elements[0][0] * e1133_1331 - m.elements[0][1] * e1033_1330 + m.elements[0][3] * e1031_1130;
		auto t23 = -m.elements[0][0] * e1123_1321 + m.elements[0][1] * e1023_1320 - m.elements[0][3] * e1021_1120;
		auto t30 = -m.elements[1][0] * e2132_2231 + m.elements[1][1] * e2032_2230 - m.elements[1][2] * e2031_2130;
		auto t31 =  m.elements[0][0] * e2132_2231 - m.elements[0][1] * e2032_2230 + m.elements[0][2] * e2031_2130;
		auto t32 = -m.elements[0][0] * e1132_1231 + m.elements[0][1] * e1032_1230 - m.elements[0][2] * e1031_1130;
		auto t33 =  m.elements[0][0] * e1122_1221 - m.elements[0][1] * e1022_1220 + m.elements[0][2] * e1021_1120;
		Matrix r;
		r.elements[0][0] =  det * t00;
		r.elements[0][1] =  det * t01;
		r.elements[0][2] =  det * t02;
		r.elements[0][3] =  det * t03;
		r.elements[1][0] =  det * t10;
		r.elements[1][1] =  det * t11;
		r.elements[1][2] =  det * t12;
		r.elements[1][3] =  det * t13;
		r.elements[2][0] =  det * t20;
		r.elements[2][1] =  det * t21;
		r.elements[2][2] =  det * t22;
		r.elements[2][3] =  det * t23;
		r.elements[3][0] =  det * t30;
		r.elements[3][1] =  det * t31;
		r.elements[3][2] =  det * t32;
		r.elements[3][3] =  det * t33;
		return r;
	}

	static Matrix Transpose(Matrix m) {

		mixin({
			string result = "Matrix r;";
			foreach (i;0..4) {
				foreach (j;0..4) {
					result ~= "r.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = ";
					result ~= "m.elements[" ~ to!string(j) ~ "][" ~ to!string(i) ~ "];";
				}
			}
			result ~= "return r;";
			return result;
		}());
	}

	static Matrix fromString(string str) {
		Matrix r;
		int row = 0;
		foreach (line; str.split("\n")) {
			auto strs = line.chomp.split(",");
			if (strs.length == 4) {
				foreach (int c, s; strs) {
					s = s.split[$-1];
					r[c, row] = to!U(s);
				}
				row++;
			}
			if (row == 4) break;
		}
		return r;
	}

	string getString(U epsilon = 0) {
		mixin(getStringCode());
	}

	ref U opIndex(int x, int y) {
		return elements[x][y];
	}

	U[] array() {
		mixin(getConvertCode());
		return arrayForConvert;
	}
}

alias Matrix!(float) mat4;
alias Matrix!(double) mat4d;

//============================================================================以下mixin用の関数達

private static string multMMCode() {
	string code = "";
	foreach (x;0..4) {
		foreach (y; 0..4) {
			code ~= "result.elements[" ~ to!string(x) ~ "][" ~ to!string(y) ~ "] = ";
			foreach (i; 0..4) {
				code ~= "+ elements[" ~ to!string(i) ~ "][" ~ to!string(y) ~ "] * m.elements[" ~ to!string(x) ~ "][" ~ to!string(i) ~ "]";
			}
			code ~= ";";
		}
	}
	return code;
}

private static string multMVCode() {
	string code;
	foreach (i; 0..4) {
		code ~= "result.elements[" ~ to!string(i) ~ "] = ";
		foreach (j; 0..4) {
			code ~= "+ elements[" ~ to!string(j) ~ "][" ~ to!string(i) ~ "] * v[" ~ to!string(j) ~ "]";
		}
		code ~= ";";
	}
	return code;
}

private static string multMVAssignCode() {
	string code;
	foreach (i; 0..4) {
		code ~= "this.elements[" ~ to!string(i) ~ "] = ";
		foreach (j; 0..4) {
			code ~= "+ elements[" ~ to!string(j) ~ "][" ~ to!string(i) ~ "] * v[" ~ to!string(j) ~ "]";
		}
		code ~= ";";
	}
	return code;
}

private static string getIdentityCode() {
	string code;
	foreach (i; 0..4) {
		foreach (j; 0..4) {
			code ~= "result.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = ";
			if (i == j) code ~= "1;";
			else code ~= "0;";
		}
	}
	return code;
}

private static string getTranslationCode() {
	string code;
	foreach (i; 0..4) {
		foreach (j; 0..4) {
			code ~= "result.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = ";
			if (i == j) code ~= "1;";
			else if (i == 3) code ~= "vec[" ~ to!string(j) ~ "];";
			else code ~= "0;";
		}
	}
	return code;
}

private static string getScaleCode() {
	string code;
	foreach (i; 0..4) {
		foreach (j; 0..4) {
			code ~= "result.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = ";
			if (i == 3 && j == 3) code ~= "1;";
			else if (i == j) code ~= "vec[" ~ to!string(i) ~ "];";
			else code ~= "0;";
		}
	}
	return code;
}

private static string getRotAxisCode() {
	string code;
	foreach (i; 0..4) {
		foreach (j; 0..4) {
			code ~= "result.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = ";
			if (i == 3 && j == 3)
				code ~= "1;";
			else if (i == 3 || j == 3)
				code ~= "0;";
			else if (i == j)
				code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)+c;";
			else if (j == (i+1)%3)
				code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)+v[" ~ to!string((i+2)%3) ~ "]*s;";
			else
				code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)-v[" ~ to!string((i+1)%3) ~ "]*s;";
		}
	}
	return code;
}

private static string getOpBinaryMMCode(string op) {
	string code;
	foreach (i; 0..4) {
		code ~= "result.elements[" ~ to!string(i) ~ "][] = elements[" ~ to!string(i) ~ "][]" ~ op ~ "m.elements[" ~ to!string(i) ~ "][];";
	}
	return code;
}

private static string getOpBinaryMSCode(string op) {
	string code;
	foreach (i; 0..4) {
		code ~= "result.elements[" ~ to!string(i) ~ "][] = elements[" ~ to!string(i) ~ "][]" ~ op ~ "s;";
	}
	return code;
}

private static string getOpAssignMMCode(string op) {
	string code;
	foreach (i; 0..4) {
		code ~= "this.elements[" ~ to!string(i) ~ "][] = elements[" ~ to!string(i) ~ "][]" ~ op ~ "m.elements[" ~ to!string(i) ~ "][];";
	}
	return code;
}

private static string getLookAtCode() {
	string code;
	code ~= "Vector!(U,3) side;";
	//sideを外積で生成
	foreach (i; 0..3) {
		code ~= "side.elements[" ~ to!string(i) ~ "] = up.elements[" ~ to!string((i+1)%3) ~ "] * vec.elements[" ~
			to!string((i+2)%3) ~ "] - up.elements[" ~
			to!string((i+2)%3) ~ "] * vec.elements[" ~ to!string((i+1)%3) ~ "];";
	}
	//sideを正規化
	code ~= "U length = sqrt(";
	foreach (i; 0..3) {
		code ~="+side.elements[" ~ to!string(i) ~ "] * side.elements[" ~ to!string(i) ~ "]";
	}
	code ~= ");";
	foreach (i; 0..3) {
		code ~= "side.elements[" ~ to!string(i) ~ "] /= length;";
	}
	//upを再計算
	foreach (i; 0..3) {
		code ~= "up.elements[" ~ to!string(i) ~ "] = vec.elements[" ~ to!string((i+1)%3) ~ "] * side.elements[" ~
			to!string((i+2)%3) ~ "] - vec.elements[" ~
			to!string((i+2)%3) ~ "] * side.elements[" ~ to!string((i+1)%3) ~ "];";
	}
	//upを正規化
	code ~= "length = sqrt(";
	foreach (i; 0..3) {
		code ~="+up.elements[" ~ to!string(i) ~ "] * up.elements[" ~ to!string(i) ~ "]";
	}
	code ~= ");";
	foreach (i; 0..3) {
		code ~= "up.elements[" ~ to!string(i) ~ "] /= length;";
	}

	//行列
	foreach (i; 0..3) {
		code ~= "result.elements[" ~ to!string(i) ~ 
			"][0] = side.elements[" ~ to!string(i) ~ "];"; 
	}

	foreach (i; 0..3) {
		code ~= "result.elements[" ~ to!string(i) ~
			"][1] = up.elements[" ~ to!string(i) ~ "];";
	}
	foreach (i; 0..3) {
		code ~= "result.elements[" ~ to!string(i) ~
			"][2] = vec.elements[" ~ to!string(i) ~ "];";
	}
	foreach (i; 0..3) {
		code ~= "result.elements[3][" ~ to!string(i) ~
			"] = ";
		foreach (j; 0..3) {
			code ~= "-eye.elements[" ~ to!string(j) ~ "] * result.elements[" ~ to!string(j)
				~ "][" ~ to!string(i) ~ "]";
		}
		code ~= ";";
	}
	foreach (i; 0..3) {
		code ~= "result.elements[" ~ to!string(i) ~ "][3] = 0;";
	}
	code ~= "result.elements[3][3] = 1;";
	return code;
}

private static string getOrthoCode() {
	string code;
	foreach (i; 0..4) {
		if (i != 0) code ~= "result.elements[" ~ to!string(i) ~ "][0] = 0;";
	}
	foreach (i; 0..4) {
		if (i != 1) code ~= "result.elements[" ~ to!string(i) ~ "][1] = 0;";
	}
	foreach (i; 0..4) {
		if (i < 2) code ~= "result.elements[" ~ to!string(i) ~ "][2] = 0;";
	}
	foreach (i; 0..3) {
		code ~= "result.elements[" ~ to!string(i) ~ "][3] = 0;";
	}
	code ~= "result.elements[0][0] = 2 / width;";
	code ~= "result.elements[1][1] = 2 / height;";
	code ~= "result.elements[2][2] = 1 / (farZ - nearZ);";
	code ~= "result.elements[3][2] = nearZ / (nearZ - farZ);";
	code ~= "result.elements[3][3] = 1;";
	return code;
}

private static string getPerspectiveCode() {
	string code;
	foreach (i; 0..4) {
		if (i != 0) code ~= "result.elements[" ~ to!string(i) ~ "][0] = 0;";
	}
	foreach (i; 0..4) {
		if (i != 1) code ~= "result.elements[" ~ to!string(i) ~ "][1] = 0;";
	}
	foreach (i; 0..4) {
		if (i < 2) code ~= "result.elements[" ~ to!string(i) ~ "][2] = 0;";
	}
	foreach (i; 0..4) {
		if (i != 2) code ~= "result.elements[" ~ to!string(i) ~ "][3] = 0;";
	}
	code ~= "result.elements[0][0] = aspectWperH / tan(fovy/2);";
	code ~= "result.elements[1][1] = 1 / tan(fovy/2);";
	code ~= "result.elements[2][2] = 1 / (farZ - nearZ);";
	code ~= "result.elements[3][2] = nearZ / (nearZ - farZ);";
	code ~= "result.elements[2][3] = 1;";
	return code;
}

private static string getStringCode() {
	string code = "U a;";
	code ~= "string r;";
	foreach (y; 0..4) {
		foreach (x; 0..4) {
			code ~= "a = elements[" ~ to!string(x) ~ "][" ~ to!string(y) ~ "];";
			code ~= "if (abs(a) < epsilon) a = 0;";
			code ~= "r ~= to!string(a);";
			if (x < 3) code ~= " r ~= \",\";";
		}
		code ~= "r ~= \"\n\";";
	}
	code ~= "return r;";
	return code;
}

private static string getConvertCode() {
	string code;
	foreach (y; 0..4) {
		foreach (x; 0..4) {
			code ~= "arrayForConvert[" ~ to!string(y*4+x) ~ "] = elements[" ~ to!string(x) ~ "]["
				~ to!string(y) ~ "];";
		}
	}
	return code;
}

private static string getCopyCode(string identifier) {
	string code;
	foreach (x; 0..4) {
		foreach (y; 0..4) {
			code ~= "this.elements[" ~ to!string(x) ~ "][" ~ to!string(y) ~ "]
				= " ~ identifier ~ ".elements[" ~ to!string(x) ~ "][" ~ to!string(y) ~ "];";
		}
	}
	return code;
}