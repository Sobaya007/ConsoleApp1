module sbylib.primitive.sphere;

import sbylib;

class Sphere : Primitive {

	static{
		private VAO vao;
		private VBO vertexVBO;
		private VBO normalVBO;
		private ShaderProgram sp;
		private IBO index;
		private bool initFlag = false;
		private vec3[] vertex;
	}

	this()  {
		if (!initFlag) {
			sp = ShaderStore.getShader("NormalShow");

			enum goldenRatio = (1 + sqrt(5.0f)) / 2;

			vertex ~= vec3(-1, +goldenRatio, 0);
			vertex ~= vec3(+1, +goldenRatio, 0);
			vertex ~= vec3(-1, -goldenRatio, 0);
			vertex ~= vec3(+1, -goldenRatio, 0);

			vertex ~= vec3(0, -1, +goldenRatio);
			vertex ~= vec3(0, +1, +goldenRatio);
			vertex ~= vec3(0, -1, -goldenRatio);
			vertex ~= vec3(0, +1, -goldenRatio);

			vertex ~= vec3(+goldenRatio, 0, -1);
			vertex ~= vec3(+goldenRatio, 0, +1);
			vertex ~= vec3(-goldenRatio, 0, -1);
			vertex ~= vec3(-goldenRatio, 0, +1);

			foreach (i; 0..vertex.length) vertex[i] = normalize(vertex[i]);

			uint[] indices;
			indices ~= [ 5, 11,  0];
			indices ~= [ 1,  5,  0];
			indices ~= [ 7,  1,  0];
			indices ~= [10,  7,  0];
			indices ~= [11, 10,  0];

			indices ~= [ 9,  5,  1];
			indices ~= [ 4, 11,  5];
			indices ~= [ 2, 10, 11];
			indices ~= [ 6,  7, 10];
			indices ~= [ 8,  1,  7];

			indices ~= [ 4,  9,  3];
			indices ~= [ 2,  4,  3];
			indices ~= [ 6,  2,  3];
			indices ~= [ 8,  6,  3];
			indices ~= [ 9,  8,  3];

			indices ~= [ 5,  9,  4];
			indices ~= [11,  4,  2];
			indices ~= [10,  2,  6];
			indices ~= [ 7,  6,  8];
			indices ~= [ 1,  8,  9];

			enum int recursionLevel = 3;

			int idx = 12;
			//解像度細かく
			foreach (k; 0..3) {
				uint[] indices2;
				foreach (i; 0..indices.length/3) { //各面について
					vec3 p0 = vertex[indices[i*3]];
					vec3 p1 = vertex[indices[i*3+1]];
					vec3 p2 = vertex[indices[i*3+2]];

					vec3 v0 = (p0 + p1) / 2;
					vec3 v1 = (p1 + p2) / 2;
					vec3 v2 = (p2 + p0) / 2;

					v0 = normalize(v0);
					v1 = normalize(v1);
					v2 = normalize(v2);

					vertex ~= v0;
					vertex ~= v1;
					vertex ~= v2;

					indices2 ~= [indices[i*3], idx, idx+2];
					indices2 ~= [idx, indices[i*3+1], idx+1];
					indices2 ~= [idx+2,idx+1,indices[i*3+2]];
					indices2 ~= [idx, idx+1, idx+2];
					idx += 3;
				}
				indices = indices2.dup;
			}
			float[] vertexArray;
			foreach (v; vertex) vertexArray ~= v.array;

			vertexVBO = new VBO( vertexArray, VBO.Frequency.STREAM);

			//法線
			float[] normal;

			foreach (v; vertex) {
				auto n = normalize(v);
				normal ~= n.array;
			}
			normalVBO = new VBO(normal, VBO.Frequency.STATIC);

			//インデックス
			index = new IBO(indices, IBO.Frequency.STATIC);

			//VAO設置
			vao = new VAO;
			vao.shaderProgram = sp;
			vao.mode = GL_TRIANGLES;

			vao.Bind();
			{	

				normalVBO.Bind();
				{
					glEnableClientState(GL_NORMAL_ARRAY);
					glNormalPointer(GL_FLOAT, 0, null);
				}
				normalVBO.UnBind();

				vertexVBO.Bind();
				{
					glEnableClientState(GL_VERTEX_ARRAY);
					glVertexPointer(3, GL_FLOAT, 0, null);
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
		vao.Draw(index);
	}
}