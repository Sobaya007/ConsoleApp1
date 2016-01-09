module sbylib.utils.functions;

import sbylib;

void SendBufferData(GLenum e)(inout int bufferID, inout float[] data) {
	glBindBuffer(GL_ARRAY_BUFFER, bufferID);
	glBufferData(GL_ARRAY_BUFFER, data.length * float.sizeof, data.ptr, e);
}

alias SendBufferData!(GL_STATIC_DRAW) StaticSendBufferData;
alias SendBufferData!(GL_DYNAMIC_DRAW) DynamicSendBufferData;

bool contains(T)(T value, T[] array... ) {
	foreach( e; array )
		if( value == e )
			return true;
	return false;
}

T computeSignedVolume(T)(Vector!(T, 3)[4] positions...) {
	alias Vector!(T, S) vec;
	mixin({
		string code;
		foreach (i; 0..3) {
			code ~= "vec v" ~ to!string(i) ~ " = positions[" ~to!string(i+1) ~ "] - positions[0];";
		}
		code ~= "return ";
		foreach (i; 0..3) {
			code ~= "+v" ~ to!string(i) ~ ".x * v" ~ to!string((i+1)%3) ~ ".y * v" ~ to!string((i+2)%3) ~ ".z";
		}
		foreach (i; 0..3) {
			code ~= "-v" ~ to!string(i) ~ ".x * v" ~ to!string((i+2)%3) ~ ".y * v" ~ to!string((i+1)%3) ~ ".z";
		}
		return code;
	}());
}

void sbywrite(alias v)() {
	writeln(v.stringof, "=", v);
}

string toString(int i) {
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

bool Or(T)(bool delegate(T) func, T[] elements...) {
	foreach (e; elements) if (func(e)) return true;
	return false;
}

bool And(T)(bool delegate(T) func, T[] elements...) {
	foreach (e; elements) if (!func(e)) return false;
	return true;
}

private VAO vao;
private VBO vertexVBO;
private ShaderProgram drawRect;

void FunctionsInit(){
	vao = new VAO;
	vao.Bind();
	{
		float[] vertex = [-1,-1, +1,-1, -1,+1, +1,+1];
		vertexVBO = new VBO(vertex, VBO.Frequency.STATIC);
		vertexVBO.Bind();
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, null);
		vertexVBO.UnBind();
	}
	vao.UnBind();
	vao.mode = GL_TRIANGLE_STRIP;
}

void DrawRect(float cx, float cy, float width, float height, vec4 color = vec4(1,1,1,1)) {
	ShaderProgram sp = ShaderStore.getShader("DrawRect");
	sp.SetUniform!(4, "color")(color.array);
	DrawRectWidthShader(cx, cy, width, height, sp);
}

void DrawImage(float cx, float cy, float width, float height, TextureObject tex) {
	ShaderProgram sp = ShaderStore.getShader("DrawImage");
	sp.SetTexture(tex);
	DrawRectWidthShader(cx, cy, width, height, sp);
}

void DrawRectWidthShader(float cx, float cy, float width, float height, ShaderProgram sp) {
	vao.shaderProgram = sp;
	vao.SetUniform!(1, "cx")(cx);
	vao.SetUniform!(1, "cy")(cy);
	vao.SetUniform!(1, "width")(width);
	vao.SetUniform!(1, "height")(height);
	vao.SetUniform!(1, "ww")(CurrentWindow.ViewportWidth);
	vao.SetUniform!(1, "wh")(CurrentWindow.ViewportHeight);
	glDisable(GL_DEPTH_TEST);
	vao.Draw();
	glEnable(GL_DEPTH_TEST);
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