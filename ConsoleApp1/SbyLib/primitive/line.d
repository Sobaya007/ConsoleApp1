module sbylib.primitive.line;

import sbylib;

class Line : Primitive {
	private VAO vao;
	private VBO vertexVBO;
	private ShaderProgram sp;

	this(vec3 start, vec3 end, ShaderProgram sp = ShaderStore.getShader("SimpleColor"))  {
		this.sp = sp;
		sp.SetUniform!(4, "color")([0,0,1,1]);
		vertexVBO = new VBO(start.array ~ end.array, VBO.Frequency.STATIC);
		vao = new VAO;
		vao.shaderProgram = sp;
		vao.mode = GL_LINES;

		vao.Bind();
		{	
			vertexVBO.Bind();
			{
				glEnableClientState(GL_VERTEX_ARRAY);
				glVertexPointer(3, GL_FLOAT, 0, null);
			}
			vertexVBO.UnBind();
		}
		vao.UnBind();
		glLineWidth(10f);
	}

	override void Draw() {
		sp.SetUniformMatrix!(4,"mWorld")(GetWorldMatrix.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw();
	}
}