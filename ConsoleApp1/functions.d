module sbylib.utils.functions;

import std.string;
import derelict.opengl3.gl;

void SendBufferData(GLenum e)(inout int bufferID, inout float[] data) {
	glBindBuffer(GL_ARRAY_BUFFER, bufferID);
	glBufferData(GL_ARRAY_BUFFER, data.length * float.sizeof, data.ptr, e);
}

alias SendBufferData!(GL_STATIC_DRAW) StaticSendBufferData;
alias SendBufferData!(GL_DYNAMIC_DRAW) DynamicSendBufferData;

static bool contains(T)(T value, T[] array... ) {
	foreach( e; array )
		if( value == e )
			return true;
	return false;
}


static string toString(int i) {
	if (i == 0) return "0";
	char[] s;
	while (i > 0) {
		s ~= cast(char)('0' + i % 10);
		i /= 10;
	}
	string r;
	foreach_reverse (c; s) r ~= c;
	return r;
}

mixin template CreateSetter(alias vary, string setterExtCode = "") {
	@property {
		mixin("void " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "_(" ~ typeof(vary).stringof ~ " " ~ vary.stringof ~ ") {"
			~ "this." ~ vary.stringof ~ " = " ~ vary.stringof ~ ";" ~ setterExtCode ~ "}");
	}
}

mixin template CreateGetter(alias vary, string getterExtCode = "") {
	@property {
		mixin(typeof(vary).stringof ~ " " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "() {"
			~ getterExtCode
			~ "return " ~ vary.stringof ~ ";}");
	}
}

mixin template CreateSetterGetter(alias vary, string setterExtCode = "", string getterExtCode = "") {
	@property {
		mixin("void " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "(" ~ typeof(vary).stringof ~ " " ~ vary.stringof ~ ") {"
			~ "this." ~ vary.stringof ~ " = " ~ vary.stringof ~ ";" ~ setterExtCode ~ "}");
		mixin(typeof(vary).stringof ~ " " ~ std.string.capitalize([vary.stringof[0]]) ~ vary.stringof[1..$] ~ "() {"
			~ getterExtCode
			~ "return " ~ vary.stringof ~ ";}");
	}
}

//triggerの変更があったらtargetの更新を強制する
mixin template CacheVar(alias trigger, alias target, string updateFunc) {
	static if (!__traits(hasMember, typeof(this), target.stringof ~ "_update_flag")) {
		mixin("private bool " ~ target.stringof ~ "_update_flag = true;");
	}
	@property {
		//triggerのSetterを宣言
		mixin CreateSetter!(trigger, target.stringof ~ "_update_flag = true;");
		//triggerのGetterを宣言
		mixin CreateGetter!(trigger, "");
		mixin CreateSetter!(target, "");
		//targetのGetterを宣言
		mixin CreateGetter!(
			target,
			"if (" ~ target.stringof ~ "_update_flag) {"
			~ target.stringof ~ "_update_flag = false;"
			~ target.stringof ~ " = " ~ updateFunc ~ "();}"
		);
	}
}