module sbylib.utils.functions;

import sbylib;

bool contains(T)(T value, T[] array... ) {
	foreach( e; array )
		if( value == e )
			return true;
	return false;
}

T computeSignedVolume(T)(Vector!(T, 3) positions[4]) {
	mixin({
		string code;
		foreach (i; 0..3) {
			code ~= "Vector!(T,3) v" ~ to!string(i) ~ " = positions[" ~to!string(i+1) ~ "] - positions[0];\n";
		}
		code ~= "return ";
		foreach (i; 0..3) {
			code ~= "+v" ~ to!string(i) ~ ".x * v" ~ to!string((i+1)%3) ~ ".y * v" ~ to!string((i+2)%3) ~ ".z\n";
		}
		foreach (i; 0..3) {
			code ~= "-v" ~ to!string(i) ~ ".x * v" ~ to!string((i+2)%3) ~ ".y * v" ~ to!string((i+1)%3) ~ ".z\n";
		}
		code ~= ";";
		return code;
	}());
}

T computeUnSignedArea(T)(Vector!(T,3) positions[3]) {
	return length(cross(positions[2] - positions[0], positions[1] - positions[0]));
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

private VAO vaoRect;
private VBO vertexRectVBO;
private VAO vaoLine;
private VBO vertexLineVBO;
private ShaderProgram drawRect;

void FunctionsInit(){
	vaoRect = new VAO;
	vaoRect.Bind();
	{
		float[] vertex = [-1,-1, +1,-1, -1,+1, +1,+1];
		vertexRectVBO = new VBO(vertex, VBO.Frequency.STATIC);
		vertexRectVBO.Bind();
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, null);
		vertexRectVBO.UnBind();
	}
	vaoRect.UnBind();
	vaoRect.mode = GL_TRIANGLE_STRIP;

	vaoLine = new VAO;
	vaoLine.Bind;
	{
		float[] vertex =
		[0,0,0,1,
		10,10,0,1];
		vertexLineVBO = new VBO(vertex, VBO.Frequency.STATIC);
		vertexLineVBO.Bind;
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(4, GL_FLOAT, 0, null);
		vertexLineVBO.UnBind;
	}
	vaoLine.UnBind;
	vaoLine.mode = GL_LINES;
}

void DrawRect(float cx, float cy, float width, float height, vec4 color = vec4(1,1,1,1)) {
	ShaderProgram sp = ShaderStore.getShader("DrawRect");
	sp.SetUniform!(1, "cx")(cx);
	sp.SetUniform!(1, "cy")(cy);
	sp.SetUniform!(1, "width")(width);
	sp.SetUniform!(1, "height")(height);
	sp.SetUniform!(1, "ww")(CurrentWindow.ViewportWidth);
	sp.SetUniform!(1, "wh")(CurrentWindow.ViewportHeight);
	sp.SetUniform!(4, "color")(color.array);
	DrawRectWithShader(cx, cy, width, height, sp);
}

void DrawImage(float cx, float cy, float width, float height, TextureObject tex) {
	ShaderProgram sp = ShaderStore.getShader("DrawImage");
	sp.SetUniform!(1, "cx")(cx);
	sp.SetUniform!(1, "cy")(cy);
	sp.SetUniform!(1, "width")(width);
	sp.SetUniform!(1, "height")(height);
	sp.SetUniform!(1, "ww")(CurrentWindow.ViewportWidth);
	sp.SetUniform!(1, "wh")(CurrentWindow.ViewportHeight);
	sp.SetTexture(tex);
	DrawRectWithShader(cx, cy, width, height, sp);
}

void DrawRectWithShader(float cx, float cy, float width, float height, ShaderProgram sp) {
	vaoRect.shaderProgram = sp;
	glDisable(GL_DEPTH_TEST);
	vaoRect.Draw();
	glEnable(GL_DEPTH_TEST);
}

void DrawLine(vec3 p0, vec3 p1, vec4 color = vec4(1,1,1,1)) {
	vaoLine.shaderProgram = ShaderStore.getShader("SimpleColor");
	vaoLine.SetUniformMatrix!(4, "mWorld")(mat4.Identity.array);
	vaoLine.SetUniformMatrix!(4, "mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
	vaoLine.SetUniform!(4, "color")(color.array);
	vertexLineVBO.Update(p0.array ~ 1 ~ p1.array ~ 1);
	vaoLine.Draw;
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