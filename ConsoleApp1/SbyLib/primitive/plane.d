module sbylib.primitive.plane;

import sbylib.imports;

class Plane : Primitive {
	static{
		private VAO vao;
		private VBO vertexVBO;
		private VBO normalVBO;
		private VBO texcoordVBO;
		private bool initFlag = false;
	}
	private ShaderProgram sp;

	this(ShaderProgram sp = ShaderStore.getShader("NormalShow"))  {
		this.sp = sp;
		if (!initFlag) {

			vertexVBO = new VBO( [
				-1,0,-1,1f,
				+1,0,-1,1,
				+1,0,+1,1,
				-1,0,+1,1,
			], VBO.Frequency.DYNAMIC);
			vao = new VAO;
			vao.shaderProgram = sp;
			vao.mode = GL_QUADS;

			vao.Bind();
			{	
				normalVBO = new VBO([0,1,0,0,1,0,0,1,0,0,1,0], VBO.Frequency.STATIC);

				normalVBO.Bind();
				{
					glEnableClientState(GL_NORMAL_ARRAY);
					glNormalPointer(GL_FLOAT, 0, null);
				}
				normalVBO.UnBind();

				texcoordVBO = new VBO([0,0, 1,0, 1,1, 0,1], VBO.Frequency.STATIC);

				texcoordVBO.Bind();
				{
					glEnableClientState(GL_TEXTURE_COORD_ARRAY);
					glTexCoordPointer(2,GL_FLOAT, 0, null);
				}
				texcoordVBO.UnBind();

				vertexVBO.Bind();
				{
					glEnableClientState(GL_VERTEX_ARRAY);
					glVertexPointer(4, GL_FLOAT, 0, null);
				}
				vertexVBO.UnBind();
			}
			vao.UnBind();
			initFlag = true;
		}
	}

	override void Draw() {
		sp.SetUniformMatrix!(4,"mWorld")(GetWorldMatrix.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw();
	}
}