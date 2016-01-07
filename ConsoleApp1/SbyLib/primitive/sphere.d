module sbylib.primitive.sphere;

import sbylib.imports;

class Sphere : Primitive {

	static{
		private VAO vao;
		private VBO vertexVBO;
		private VBO normalVBO;
		private ShaderProgram sp;
		private IBO index;
		private bool initFlag = false;
	}

	this()  {
		if (!initFlag) {
			sp = ShaderStore.getShader("NormalShow");

			vec3[] vertex;

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

			float[] vertexArray;
			foreach (v; vertex) vertexArray ~= v.array;

			vertexVBO = new VBO( vertexArray, VBO.Frequency.DYNAMIC);

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

			float[] normal;

			foreach (i; 0..indices.length/3) {
				auto p0 = vertex[indices[i*3+0]];
				auto p1 = vertex[indices[i*3+1]];
				auto p2 = vertex[indices[i*3+2]];
				auto n = normalize(cross(p1 - p0, p2 - p0));
				normal ~= n.array;
			}
			normalVBO = new VBO(normal, VBO.Frequency.DYNAMIC);

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

			index = new IBO(indices, IBO.Frequency.STATIC);
		}
	}

	override void Draw() {
		sp.SetUniformMatrix!(4,"mWorld")(GetWorldMatrix.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw(index);
	}
}