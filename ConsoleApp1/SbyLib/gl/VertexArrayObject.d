module sbylib.gl.VertexArrayObject;

import sbylib.imports;

class VertexArrayObject(T) {

	alias VertexBufferObject!T VBO_T;
	immutable uint vaoID;
	ShaderProgram shaderProgram;
	VBO_T vertex, texcoord;

	GLenum mode = GL_TRIANGLE_STRIP;

	this(int vertexCount) {
		this(null, vertexCount);
	}

	this(string vsPath, string fsPath, int vertexCount) {
		this(new ShaderProgram(vsPath, fsPath, ShaderProgram.InputType.FilePath), vertexCount);
	}

	this(ShaderProgram sProgram, int vertexCount, VBO_T.Frequency frequency = VBO_T.Frequency.STATIC) {
		uint vao;
		glGenVertexArrays(1, &vao);
		this.vaoID = vao;
		glBindVertexArray(vao);
		this.shaderProgram = sProgram;
		this.vertex   = new VBO_T(new T[vertexCount*3], frequency);
		this.texcoord = new VBO_T(new T[vertexCount*2], frequency);
	}

	~this() {
		glDeleteVertexArrays(1, &vaoID);
	}

	void UpdateVertex(float[] position = null) {
		glBindVertexArray(vaoID);
		assert(shaderProgram, "Shader is not set");
		shaderProgram.SetVertex(vertex, position);
	}

	void UpdateTexcoords(float[] texcoords = null) {
		glBindVertexArray(vaoID);
		assert(shaderProgram, "Shader is not set");
		shaderProgram.SetTexcoord(texcoord, texcoords);
	}

	void Bind() const {
		glBindVertexArray(vaoID);
	}

	void UnBind() const {
		glBindVertexArray(0);
	}

	void Draw() const {
		Bind();
		if (shaderProgram) {
			shaderProgram.Use();
			shaderProgram.Uniform();
		}
		glDrawArrays(mode, 0, 4);
		UnBind();
	}

	void Draw(IBO index) const {
		Bind();
		if (shaderProgram) {
			shaderProgram.Use();
			shaderProgram.Uniform();
		}
		index.Bind();
		glDrawElements(mode, index.length, GL_UNSIGNED_INT, null);
		index.UnBind();
		UnBind();
	}

	alias shaderProgram this;
}

alias VertexArrayObject!float VAO;