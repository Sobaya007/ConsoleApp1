module sbylib.primitive;

import sbylib.imports;

abstract class Primitive {
	public abstract void Draw();

	protected mat4 mat = mat4.Identity;

	void opOpAssign(string op)(vec3 v) {
		static if (op == "+") {
			mat = mat * mat4.Translation(v);
		} else if (op == "-") {
			mat = mat * mat4.Translation(-v);
		} else if (op == "*") {
			mat = mat * mat4.Scale(v);
		} else if (op == "/") {
			mat = mat * mat4.Scale(vec3(1.0f / v.x, 1.0f / v.y, 1.0f / v.z));
		}
	}
}

class Box : Primitive {

	private VAO[6] vao;
	private VBO vertexVBO;
	private VBO[6] normalVBO;
	private ShaderProgram sp;
	private IBO[6] index;

	this() {
		sp = new ShaderProgram(
							   "
							   uniform mat4 mWorld;
							   uniform mat4 mViewProj;
							   varying vec3 n;

							   void main() {
							   gl_Position = mViewProj * mWorld * gl_Vertex;
							   n = gl_Normal;
							   }",
							   "
							   varying vec3 n;
							   void main() {
							   gl_FragColor = vec4(n * .5 + .5,1);
							   }",
							   ShaderProgram.InputType.SourceCode);

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
		index[0] = new IBO([0,1,3,2], IBO.Frequency.DYNAMIC);
		index[1] = new IBO([4,5,7,6], IBO.Frequency.DYNAMIC);
		index[2] = new IBO([2,3,7,6], IBO.Frequency.DYNAMIC);
		index[3] = new IBO([0,1,5,4], IBO.Frequency.DYNAMIC);
		index[4] = new IBO([1,3,7,5], IBO.Frequency.DYNAMIC);
		index[5] = new IBO([0,2,6,4], IBO.Frequency.DYNAMIC);
	}

	override void Draw() {
		for (int i = 0; i < 6; i++) {
			auto f = {
				sp.SetUniformMatrix!(4,"mWorld")(mat.array);
				sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
			};
			f();
			vao[i].Draw(index[i]);
		}
	}
}