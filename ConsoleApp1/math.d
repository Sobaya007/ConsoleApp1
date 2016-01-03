module sbylib.math;

import std.conv;
import std.math;
import std.string;
import std.stdio;

U ToRad(U)(U angle) {
	return angle * PI / 180;
}

U ToDeg(U)(U angle) {
	return angle * 180 / PI;
}

//T型のS個のベクトル
struct Vector(T, int S) {
private:
	T[S] elements;
public:

	static string getConstructorCode() {

		string r;
		void rec(int[] a, int j, int i) {
			//現在選択中なのがa,今j番目の選択を迫られている。仕切りは全部でi本
			if (a.length == i) {
				//選択終了。処理に入る。
				//いまaの区切りがある。
				int argCount = 0;
				int[] b;
				r ~= "this(";
				foreach (k; 0..i) {
					int elemNum = a[k] - (k == 0 ? -1 : a[k-1]); //引数の要素数
					assert(elemNum > 0);
					if (elemNum == 1) {
						r ~= "T e" ~ to!string(argCount) ~ ", ";
					} else {
						r ~= "Vector!(T," ~ to!string(elemNum) ~ ") e" ~ to!string(argCount) ~ ", ";
					}
					argCount++;
					b ~= elemNum;
				}
				int elemNum = S-1 - (i == 0 ? 0 : a[$-1]); //引数の要素数
				assert(elemNum > 0);
				if (elemNum == 1) {
					r ~= "T e" ~ to!string(argCount++);
				} else {
					r ~= "Vector!(T," ~ to!string(elemNum) ~ ") e" ~ to!string(argCount);
				}
				b ~= elemNum;
				r ~= ") {\n";
				int count = 0;
				foreach (int arg,k; b) { //k個の要素
					foreach (l; 0..k) {
						r ~= "elements[" ~ to!string(count++) ~ "] = ";
						r ~= "e" ~ to!string(arg);
						if (k == 1) r ~= ";";
						else {
							r ~= "[" ~ to!string(l) ~ "];";
						}
						r ~= "\n";
					}
				}
				r ~= "}\n";
				return;
			}
			if (j == S-1) return;//後がない。終了。
			//再帰
			rec(a ~ j, j+1,i);
			rec(a, j+1,i);
		}
		foreach (i; 0..S) {
			rec([], 0, i);
		}
		return r;
	}

	mixin(getConstructorCode());

	Vector opBinary(string op)(Vector v)
	in {
		assert(S == v.elements.length);
	}
	body {
		Vector!(T, S) result;
		mixin("result.elements[] = elements[]" ~ op ~ "v.elements[];");
		return result;
	}

	Vector opBinary(string op)(T t) {
		Vector!(T, S) result;
		mixin("result.elements[] = elements[]" ~ op ~ "t;");
		return result;
	}

	Vector opBinaryRight(string op)(T t) {
		Vector!(T, S) result;
		mixin("result.elements[] = elements[]" ~ op ~ "t;");
		return result;
	}

	private static string getUnaryCode(string op, int S) {
		string code;
		foreach (i; 0..S) {
			code ~= "result.elements[" ~ to!string(i) ~ "] = " ~ op ~ "elements[" ~ to!string(i) ~ "];";
		}
		return code;
	}

	Vector opUnary(string op)() {
		Vector!(T, S) result;
		mixin(getUnaryCode(op, S));
		return result;
	}

	void opOpAssign(string op)(Vector v)
	in {
		assert(v.elements.length == S,
			   "dest.length = " ~ to!string(S) ~ ", src.length = " ~ to!string(v.elements.length));
	}
	body {
		mixin("elements[] " ~ op ~"= v.elements[];");
	}

	void opOpAssign(string op)(T e) {
		mixin("elements[] " ~ op ~"= e;");
	}

	ref T opIndex(int idx) {
		return elements[idx];
	}

	private static string getXyzwCode() {

		const string expr = "xyzw"[0..S];

		int indexOf(string s, char c) {
			foreach (int i, ss; s) {
				if (ss == c) return i;
			}
			return -1;
		}
		string code;
		//k文字のものについて考える。xは前につくk-1文字の名前
		void func(int k, string x) {
			import sbylib.functions;
			if (k > S) return;
			//k文字目を決める
			foreach (j; 0..S) {
				if (contains(expr[j], x)) continue;
				x = x[0..k-1] ~ expr[j];
				if (k == 1) {
					code ~= "void " ~ x ~ "(T v) {";
					code ~= "elements[" ~ to!string(indexOf(expr, x[0])) ~ "] = v;";
					code ~= "}";
					code ~= "T " ~ x ~ "() {";
					code ~= "return elements[" ~ to!string(indexOf(expr, x[0])) ~ "];";
					code ~= "} ";
				} else {
					code ~= "void " ~ x ~ "(Vector!(T," ~ to!string(k) ~ ") v) {";
					foreach (l; 0..k) {
						code ~= "elements[" ~ to!string(indexOf(expr, x[l])) ~ "] = v[" ~ to!string(l) ~ "];";
					}
					code ~= "}";
					code ~= "Vector!(T," ~ to!string(k) ~ ") " ~ x ~ "() {";
					code ~= "return Vector!(T, " ~ to!string(k) ~ ")(";
					foreach (l; 0..k) {
						code ~= "elements[" ~ to!string(indexOf(expr, x[l])) ~ "]";
						if (l != k-1) code ~= ",";
					}
					code ~= ");} ";
				}

				func(k+1, x);
			}
		}
		func(1, "");
		return code;
	}


	@property {
		mixin(getXyzwCode());
	}

	auto array() {
		return elements;
	}

	string getString() {
		mixin({
			string code = "return ";
			foreach (i; 0..S) {
				code ~= "to!string(elements[" ~ to!string(i) ~ "]) ~";
				if (i != S-1) code ~= " \",\"~";
			}
			code ~= "\"\n\";";
			return code;
		}());
	}

	static Vector fromString(string str) {
		Vector r;
		auto strs = str.split[2].split(",");
		foreach (int c, s; strs) {
			r[c] = to!T(s);
		}
		return r;
	}
}

alias Vector!(float, 2) vec2;
alias Vector!(float, 3) vec3;
alias Vector!(float, 4) vec4;

private string getDotCode(int S) {
	string code = "T result = ";
	foreach (i; 0..S) {
		code ~= "+v.elements[" ~ to!string(i) ~ "] * v2.elements[" ~ to!string(i) ~ "]";
	}
	code ~= ";";
	return code;
}

private string getCrossCode3D(int S) {
	string code = "Vector!(T,S) result;";
	foreach (i; 0..S) {
		code ~= "result[" ~ to!string(i) ~ "] = v.elements[" ~ to!string((i+1)%3) ~
			"] * v2.elements[" ~ to!string((i+2)%3) ~ "] - v.elements[" ~
			to!string((i+2)%3) ~ "] * v2.elements[" ~ to!string((i+1)%3) ~ "];";
	}
	return code;
}

private static string getLengthSqCode(int S) {
	string code = "T result = ";
	foreach (i; 0..S) {
		code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
	}
	code ~= ";";
	return code;
}

private string getLengthCode(int S) {
	string code = "T result = sqrt(";
	foreach (i; 0..S) {
		code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
	}
	code ~= ");";
	return code;
}

private string getNormalizeCode(int S) {
	string code = "T length = sqrt(";
	foreach (i; 0..S) {
		code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
	}
	code ~= ");";
	code ~= "Vector!(T, S) result;";
	foreach (i; 0..S) {
		code ~= "result.elements[" ~ to!string(i) ~ "] = v.elements[" ~ to!string(i) ~ "] / length;";
	}
	return code;
}

T dot(T, int S)(Vector!(T, S) v, Vector!(T,S) v2) {
	mixin(getDotCode(S));
	return result;
}

T cross(T, int S)(Vector!(T, S) v, Vector!(T, S) v2) if (S == 2) {
	return v.x * v2.y - v.y * v2.x;
}

Vector!(T, S) cross(T, int S)(Vector!(T, S) v, Vector!(T, S) v2) if (S == 3) {
	mixin(getCrossCode3D(S));
	return result;
}

T length(T, int S)(Vector!(T, S) v) {
	mixin(getLengthCode(S));
	return result;
}

T lengthSq(T, int S)(Vector!(T, S) v) {
	mixin(getLengthCode(S));
	return result;
}

Vector!(T, S) normalize(T, int S)(Vector!(T, S) v) {
	mixin(getNormalizeCode(S));
	return result;
}

struct Matrix(U) {

	U[4][4] elements;

private:
	U[16] arrayForConvert;

	static string multMMCode() {
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

	static string multMVCode() {
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

	static string getIdentityCode() {
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

	static string getTranslationCode() {
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

	static string getScaleCode() {
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

	static string getRotAxisCode() {
		string code;
		foreach (i; 0..4) {
			foreach (j; 0..4) {
				code ~= "result.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = ";
				if (i == 3 && j == 3)
					code ~= "1;";
				else if (i == 3 || j == 3)
					code ~= "0;";
				else if (i == j)
					code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(i) ~ "]*(1-c)+c;";
				else if (j == (i+1)%3)
					code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)+v[" ~ to!string((i+2)%3) ~ "]*s;";
				else
					code ~= "v[" ~ to!string(i) ~ "]*v[" ~ to!string(j) ~ "]*(1-c)-v[" ~ to!string((i+1)%3) ~ "]*s;";
			}
		}
		return code;
	}

	static string getOpBinaryMMCode(string op) {
		string code;
		foreach (i; 0..4) {
			code ~= "result.elements[" ~ to!string(i) ~ "][] = elements[" ~ to!string(i) ~ "][]" ~ op ~ "m.elements[" ~ to!string(i) ~ "][];";
		}
		return code;
	}

	static string getOpBinaryMSCode(string op) {
		string code;
		foreach (i; 0..4) {
			code ~= "result.elements[" ~ to!string(i) ~ "][] = elements[" ~ to!string(i) ~ "][]" ~ op ~ "s;";
		}
		return code;
	}

	static string getLookAtCode() {
		string code;
		foreach (i; 0..3) {
			code ~= "result.elements[" ~ to!string(i) ~
				"][0] = up.elements[" ~ to!string((i+1)%3) ~ "] * vec.elements[" ~
				to!string((i+2)%3) ~ "] - up.elements[" ~
				to!string((i+2)%3) ~ "] * vec.elements[" ~ to!string((i+1)%3) ~ "];";
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

	static string getOrthoCode() {
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

	static string getPerspectiveCode() {
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

	static string getStringCode() {
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

	static string getConvertCode() {
		string code;
		foreach (y; 0..4) {
			foreach (x; 0..4) {
				code ~= "arrayForConvert[" ~ to!string(y*4+x) ~ "] = elements[" ~ to!string(x) ~ "]["
					~ to!string(y) ~ "];";
			}
		}
		return code;
	}

public:

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

	//	static string getInvertCode() {
	//		{
	//			//行列式
	//			string r = "det = ";
	//			foreach (i; 0..4) {
	//				foreach (j; 0..4) {
	//					if (i == j) continue;
	//					foreach (k; 0..4) {
	//						if (i == k || j == k) continue;
	//						foreach (l; 0..4) {
	//							if (i == l || j == l || k == l) continue;
	//							auto e = [i,j,k,l];
	//							//転倒数を計算
	//							auto e2 = e.dup;
	//							int count;
	//							foreach (m; 0..4) {
	//								foreach (n; m+1..4) {
	//									if (e2[m] > e2[n]) {
	//										auto tmp = e2[m];
	//										e2[m] = e2[n];
	//										e2[n] = tmp;
	//										count++;
	//									}
	//								}
	//							}
	//							if (count % 2 == 0) r ~= "+";
	//							else r ~= "-";
	//							foreach (m;0..4) {
	//								r ~= "mat.elements[" ~ to!string(m) ~ "][" ~ to!string(e[m]) ~ "]";
	//								if (m < 3) r ~= "*";
	//							}
	//							r ~= "\n";
	//						}
	//					}
	//				}
	//			}
	//			r ~= ";";
	//			//余因子展開
	//			foreach (i; 0..4) {
	//				foreach (j;0..4) {
	//					r ~= "result.elements[" ~ to!string(i) ~ "][" ~ to!string(j) ~ "] = (";
	//					foreach (k; 0..4) {
	//						if (k == i) continue;
	//						foreach (l; 0..4) {
	//							if (l == j) continue;
	//							foreach (m; 0..3) {
	//								foreach (n; 0..3) {
	//									if (m == n) continue;
	//									foreach (o; 0..3) {
	//										if (m == o || n == o) continue;
	//										auto e = [m, n, o];
	//										//転倒数を計算
	//										auto e2 = e.dup;
	//										int count = 0;
	//										foreach (p;0..3) {
	//											foreach (q; p+1..3) {
	//												if (e2[p] > e2[q]) {
	//													auto tmp = e2[p];
	//													e2[p] = e2[q];
	//													e2[q] = tmp;
	//													count++;
	//												}
	//											}
	//										}
	//										if (count % 2 == 0) r ~= " + ";
	//										else r ~= " - ";
	//										foreach (p;0..3) {
	//											r ~= "mat.elements[" ~ to!string(p) ~ "][" ~ to!string(e[p]) ~ "]";
	//											if (p < 2) r ~= " * ";
	//										}
	//									}
	//								}
	//							}
	//						}
	//					}
	//					r ~= ") / det;\n";
	//				}
	//			}
	//			return r;
	//		}
	//	}

	//	static Matrix Invert(Matrix mat) {
	//		static assert(!std.traits.isIntegral!(U), "Integral type is not allowed");
	//		Matrix result;
	//		U det;
	//		mixin(getInvertCode());
	//		return result;
	//	}

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