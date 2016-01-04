module sbylib.gl.ShaderProgram;

import sbylib.imports;

class ShaderProgram {

	static enum InputType {SourceCode, FilePath}

	immutable uint programID;
	private static uint[string] Shaders;
	void delegate()[string] attributeApply;
	void delegate()[string] uniformApply;

	Tuple!(uint, int)[int] texIDs;

	this(string vs, string fs, InputType inputType) {
		final switch (inputType) {
			case InputType.SourceCode:
				programID = getShaderProgramIDFromString(vs, fs);
				break;
			case InputType.FilePath:
				programID = GetShaderProgramID(vs, fs);
				break;
		}
	}

	~this() {
		glDeleteProgram(programID);
	}

	void Uniform() const {
		foreach (unit; texIDs.keys) {
			glActiveTexture(GL_TEXTURE0 + unit);
			glBindTexture(GL_TEXTURE_2D, texIDs[unit][0]);
			glUniform1i(texIDs[unit][1], unit);
		}
		foreach (f; uniformApply) {
			f();
		}
	}

	void SetTexture(TextureObject texObj, string locationName = "mTexture", int textureUnit = 0) {
		SetTexture(texObj.texID, locationName, textureUnit);
	}

	void SetTexture(uint texID, string locationName = "mTexture", int textureUnit = 0) {
		int sLoc = glGetUniformLocation(programID, locationName.toStringz);
		assert(sLoc != -1, locationName ~ " is not found or used in shader.");

		texIDs[textureUnit] = tuple(texID, sLoc);
	}

	void SetVertex(VBO vbo) {
		SetAttribute!(4, "mVertex")( {
			vbo.Bind();
		});
	}

	void SetAttribute(int num, string name)(void delegate() preFunc = null) {
		//頂点シェーダのattribute変数のアドレスを取得
		int vLoc = glGetAttribLocation(programID, name.toStringz);
		assert(vLoc != -1, name ~ " is not found or used in shader.");
		glEnableVertexAttribArray(vLoc);
		if (preFunc) preFunc();
		//さっきのところをmVertexってことにする
		glVertexAttribPointer(vLoc, num, GL_FLOAT, GL_FALSE, num * float.sizeof, null);
	}

	void SetUniform(int num, string name)(float[num] uniform...) {
		int loc = glGetUniformLocation(programID, name.toStringz);
		assert(loc != -1, name ~ " is not found or used in shader.");
		auto func = mixin("glUniform" ~ to!string(num) ~ "fv");
		uniformApply[name] = {func(loc, 1, uniform.ptr);};
	}

	void SetUniformMatrix(int num, string name)(float[] uniform) {
		assert(uniform.length == num * num, "Wrong length array. the length of argument must be " ~ to!string(num*num));
		int loc = glGetUniformLocation(programID, name.toStringz);
		assert(loc != -1, name ~ " is not found or used in shader.");
		auto func = mixin("glUniformMatrix" ~ to!string(num) ~ "fv");
		uniformApply[name] = {func(loc, 1, GL_TRUE, uniform.ptr);};
	}

	void Use() const {
		glUseProgram(programID);
	}

	private static int GetShaderProgramID(string vsPath, string fsPath) {
		uint *p;
		int vsID, fsID;
		if ((p = vsPath in Shaders) != null) {
			vsID = *p;
		} else {
			string vsSource = ((cast(const char[])read(vsPath))).idup;
			vsID = getVertexShaderFromString(vsSource);
		}
		if ((p = fsPath in Shaders) != null) {
			fsID = *p;
		} else {
			string fsSource = ((cast(const char[])read(fsPath))).idup;
			fsID = getFragmentShaderFromString(fsSource);
		}
		return getSP(vsID, fsID);
	}

	private static int getShaderProgramIDFromString(string vsString, string fsString) {
		int vsID = getVertexShaderFromString(vsString);
		int fsID = getFragmentShaderFromString(fsString);
		return getSP(vsID, fsID);
	}

	private static int getSP(int vsID, int fsID) {
		//シェーダプログラムを生成
		int programID = glCreateProgram();

		//シェーダプログラムと各シェーダを紐付け
		glAttachShader(programID, vsID);
		glAttachShader(programID, fsID);

		//シェーダプログラムとシェーダをリンク
		glLinkProgram(programID);

		//リンクエラーを確認
		int result;
		glGetProgramiv(programID, GL_LINK_STATUS, &result);
		if (result == GL_FALSE) {
			int logLength;
			glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &logLength);
			char[] log = new char[logLength];
			int a;
			glGetProgramInfoLog(programID, logLength, &a, log.ptr);
			assert(false, "Link Error\n" ~ to!string(log));
		}
		return programID;
	}

	private static int getVertexShaderFromString(string vsSource, string vsPath = null) {
		uint vsID, fsID;
		vsID = glCreateShader(GL_VERTEX_SHADER);
		auto str = vsSource.toStringz;
		int len = vsSource.length;
		glShaderSource(vsID, 1, &str, &len);
		glCompileShader(vsID);
		if (vsPath) Shaders[vsPath] = vsID;
		int result;
		glGetShaderiv(vsID, GL_COMPILE_STATUS, &result);
		if (result == GL_FALSE) {
			int logLength;
			glGetShaderiv(vsID, GL_INFO_LOG_LENGTH, &logLength);
			char[] log = new char[logLength];
			int a;
			glGetShaderInfoLog(vsID, logLength, &a, &log[0]);
			string errorString = "Compile Error";
			if (vsPath)
				errorString ~= "in \"" ~ vsPath ~ "\".\n";
			else
				errorString ~= ".\n";
			errorString ~= getLogString(to!string(log), vsSource);
			assert(false, errorString);
		}
		return vsID;
	}

	private static int getFragmentShaderFromString(string fsSource, string fsPath = null) {
		int fsID;
		fsID = glCreateShader(GL_FRAGMENT_SHADER);
		auto str = fsSource.toStringz;
		int len = fsSource.length;
		glShaderSource(fsID, 1, &str, &len);
		glCompileShader(fsID);
		if (fsPath) Shaders[fsPath] = fsID;
		int result;
		glGetShaderiv(fsID, GL_COMPILE_STATUS, &result);
		if (result == GL_FALSE) {
			int logLength;
			glGetShaderiv(fsID, GL_INFO_LOG_LENGTH, &logLength);
			char[] log = new char[logLength];
			int a;
			glGetShaderInfoLog(fsID, logLength, &a, log.ptr);
			string errorString = "Compile Error";
			if (fsPath)
				errorString ~= "in \"" ~ fsPath ~ "\".\n";
			else
				errorString ~= ".\n";

			errorString ~= getLogString(to!string(log), fsSource);
			assert(false, errorString);
		}
		return fsID;
	}

	private static string getLogString(string log, string sourceCode) {
		auto lines = log.splitLines;
		int[] lineNum;
		foreach (string line; lines) {
			auto strs = split(line, ":");
			if (strs.length > 0 && strs[0] == "ERROR") {
				auto c = strs[1].split[0];
				lineNum ~= to!int(c)-1;
			}
		}
		auto r = assumeSorted(lineNum);
		string result;
		auto strs = sourceCode.splitLines;
		foreach (int i, str; strs) {
			if (r.canFind(i)) {
				result ~= "▶";
				result ~= str;
			} else {
				result ~= str;
			}
			result ~= "\n";
		}
		result ~= log;
		return result;
	}
}