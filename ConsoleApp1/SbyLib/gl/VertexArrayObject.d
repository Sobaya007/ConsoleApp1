module sbylib.gl.VertexArrayObject;

import sbylib.imports;

class VertexArrayObject(T) {

	alias VertexBufferObject!T VBO_T;
	immutable uint vaoID;
	ShaderProgram shaderProgram;

	GLenum mode = GL_TRIANGLE_STRIP;

	this() {
		uint vao;
		glGenVertexArrays(1, &vao);
		this.vaoID = vao;
	}

	~this() {
		glDeleteVertexArrays(1, &vaoID);
	}

	void SetVertex(VBO vbo) {
		glBindVertexArray(vaoID);
		assert(shaderProgram, "Shader is not set");
		shaderProgram.SetVertex(vbo);
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