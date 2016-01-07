module sbylib.math.vector;

import std.conv;
import std.math;
import std.string;
import std.stdio;
import sbylib.utils.imports;

//T型のS個のベクトル
struct Vector(T, int S) {
package:
	T[S] elements;
public:

	mixin(getConstructorCode(S)); //====================================コンストラクタの宣言

	@property {
		mixin(getXyzwCode(S)); //=======================================GLSLっぽくするためのプロパティの宣言
	}

	Vector opBinary(string op)(Vector v) //=============================Vectorに対する二項演算
	in {
		assert(S == v.elements.length);
	}
	body {
		Vector!(T, S) result;
		mixin("result.elements[] = elements[]" ~ op ~ "v.elements[];");
		return result;
	}

	Vector opBinary(string op)(T t) { //================================スカラーに対する二項演算
		Vector!(T, S) result;
		mixin("result.elements[] = elements[]" ~ op ~ "t;");
		return result;
	}

	Vector opBinaryRight(string op)(T t) {
		Vector!(T, S) result;
		mixin("result.elements[] = elements[]" ~ op ~ "t;");
		return result;
	}

	Vector opUnary(string op)() { //====================================単項演算子
		Vector!(T, S) result;
		mixin(getUnaryCode(op, S));
		return result;
	}

	void opOpAssign(string op)(Vector v) //=============================ベクトルに対する代入算術演算子
	in {
		assert(v.elements.length == S,
			   "dest.length = " ~ to!string(S) ~ ", src.length = " ~ to!string(v.elements.length));
	}
	body {
		mixin("elements[] " ~ op ~"= v.elements[];");
	}

	void opOpAssign(string op)(T e) { //================================スカラーに対する代入算術演算子
		mixin("elements[] " ~ op ~"= e;");
	}

	ref T opIndex(int idx) { //=========================================添字演算子
		return elements[idx];
	}

	auto array() { //===================================================配列化
		return elements;
	}

	string GetString() { //=============================================文字列化
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

	static Vector fromString(string str) { //===========================文字列からVectorを生成
		Vector r;
		auto strs = str.split[2].split(",");
		foreach (int c, s; strs) {
			r[c] = to!T(s);
		}
		return r;
	}
}

alias Vector!(float, 2) vec2; //========================================適当にaliasしとく
alias Vector!(float, 3) vec3;
alias Vector!(float, 4) vec4;

//======================================================================以下ベクトル計算系の関数達

T dot(T, int S)(Vector!(T, S) v, Vector!(T,S) v2) {
	mixin({
		string code = "T result = ";
		foreach (i; 0..S) {
			code ~= "+v.elements[" ~ to!string(i) ~ "] * v2.elements[" ~ to!string(i) ~ "]";
		}
		code ~= ";";
		return code;
	}());
	return result;
}

T cross(T, int S)(Vector!(T, S) v, Vector!(T, S) v2) if (S == 2) {
	return v.x * v2.y - v.y * v2.x;
}

Vector!(T, S) cross(T, int S)(Vector!(T, S) v, Vector!(T, S) v2) if (S == 3) {
	mixin({
		string code = "Vector!(T,S) result;";
		foreach (i; 0..S) {
			code ~= "result[" ~ to!string(i) ~ "] = v.elements[" ~ to!string((i+1)%3) ~
				"] * v2.elements[" ~ to!string((i+2)%3) ~ "] - v.elements[" ~
				to!string((i+2)%3) ~ "] * v2.elements[" ~ to!string((i+1)%3) ~ "];";
		}
		return code;
	}());
	return result;
}

T length(T, int S)(Vector!(T, S) v) {
	mixin({
		string code = "T result = sqrt(";
		foreach (i; 0..S) {
			code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
		}
		code ~= ");";
		return code;
	}());
	return result;
}

T lengthSq(T, int S)(Vector!(T, S) v) {
	mixin({
		string code = "T result = ";
		foreach (i; 0..S) {
			code ~= "+v.elements[" ~ to!string(i) ~ "] * v.elements[" ~ to!string(i) ~ "]";
		}
		code ~= ";";
		return code;
	}());
	return result;
}

Vector!(T, S) normalize(T, int S)(Vector!(T, S) v) {
	mixin({
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
	}());
	return result;
}

//========================================================================以下mixin用の関数達

private string getConstructorCode(int S) {
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
					r ~= "T e" ~ toString(argCount) ~ ", ";
				} else {
					r ~= "Vector!(T," ~ toString(elemNum) ~ ") e" ~ toString(argCount) ~ ", ";
				}
				argCount++;
				b ~= elemNum;
			}
			int elemNum = S-1 - (i == 0 ? 0 : a[$-1]); //引数の要素数
			assert(elemNum > 0);
			if (elemNum == 1) {
				r ~= "T e" ~ toString(argCount++);
			} else {
				r ~= "Vector!(T," ~ toString(elemNum) ~ ") e" ~ toString(argCount);
			}
			b ~= elemNum;
			r ~= ") {\n";
			int count = 0;
			foreach (int arg,k; b) { //k個の要素
				foreach (l; 0..k) {
					r ~= "elements[" ~ toString(count++) ~ "] = ";
					r ~= "e" ~ toString(arg);
					if (k == 1) r ~= ";";
					else {
						r ~= "[" ~ toString(l) ~ "];";
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

private string getXyzwCode(int S) {

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
		import sbylib.utils.imports;
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

private string getUnaryCode(string op, int S) {
	string code;
	foreach (i; 0..S) {
		code ~= "result.elements[" ~ to!string(i) ~ "] = " ~ op ~ "elements[" ~ to!string(i) ~ "];";
	}
	return code;
}