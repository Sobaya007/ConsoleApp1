module sbylib.primitive.cube;

import sbylib;

class Box : Primitive {
	static{
		private VAO[6] vao;
		private VBO vertexVBO;
		private VBO[6] normalVBO;
		private ShaderProgram sp;
		private IBO[6] index;
		private bool initFlag = false;
	}

	this()  {
		if (!initFlag) {
			sp = ShaderStore.getShader("NormalShow");

			vertexVBO = new VBO( [
				-1,-1,-1,1f,
				+1,-1,-1,1,
				-1,+1,-1,1,
				+1,+1,-1,1,
				-1,-1,1,1,
				+1,-1,1,1,
				-1,+1,1,1,
				+1,+1,1,1
			], VBO.Frequency.DYNAMIC);
			vec3[6] normal = [
				vec3(0,0,-1),
				vec3(0,0,+1),
				vec3(0,+1,0),
				vec3(0,-1,0),
				vec3(-1,0,0),
				vec3(+1,0,0)
			];
			foreach (i; 0..6) {
				vao[i] = new VAO;
				vao[i].shaderProgram = sp;
				vao[i].mode = GL_QUADS;

				vao[i].Bind();
				{	
					float[] n;
					foreach (j; 0..8) n ~= normal[i].array;
					normalVBO[i] = new VBO(n, VBO.Frequency.DYNAMIC);

					normalVBO[i].Bind();
					{
						glEnableClientState(GL_NORMAL_ARRAY);
						glNormalPointer(GL_FLOAT, 0, null);
					}
					normalVBO[i].UnBind();

					vertexVBO.Bind();
					{
						glEnableClientState(GL_VERTEX_ARRAY);
						glVertexPointer(4, GL_FLOAT, 0, null);
					}
					vertexVBO.UnBind();
				}
				vao[i].UnBind();
			}
			index[0] = new IBO([0,1,3,2], IBO.Frequency.DYNAMIC); //奥
			index[1] = new IBO([6,7,5,4], IBO.Frequency.DYNAMIC); //手前
			index[2] = new IBO([2,3,7,6], IBO.Frequency.DYNAMIC); //上
			index[3] = new IBO([4,5,1,0], IBO.Frequency.DYNAMIC); //下
			index[4] = new IBO([5,7,3,1], IBO.Frequency.DYNAMIC); //左
			index[5] = new IBO([0,2,6,4], IBO.Frequency.DYNAMIC); //右
			initFlag = true;
		}
	}

	override void Draw() {
		for (int i = 0; i < 6; i++) {
			sp.SetUniformMatrix!(4,"mWorld")(GetWorldMatrix.array);
			sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
			vao[i].Draw(index[i]);
		}
	}

}