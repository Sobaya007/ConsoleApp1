module sbylib.physics.elastic.sphere;

import sbylib;

class ElasticSphere : Primitive {

	static{
		private {
			ShaderProgram sp;
			IBO index;
			bool initFlag = false;
			vec3[] vertex;
			uint[] indices;
			uint[][] pairIndex;

			immutable {
				int recursionLevel = 2;
				float R = 0.5;
				float h = 0.02;
				float zeta = 0.5;
				float omega = 1000;
				float m = 0.0001;
				float c = 2 * zeta * omega * m;
				float k = m * omega * omega;
				float deflen = R * 2 * (1 - 1 / sqrt(5.0f)) / (recursionLevel + 1);
				float friction = 0.01;
				float gravity = 10;

				float velocity_coefficient = 1 / (1+h*c/m+h*h*k/m);
				float position_coefficient = - (h*k/m) / (1+h*c/m+h*h*k/m);
			}

			class Particle {
				vec3 p;
				vec3 v;
				vec3 n;

				this(vec3 p) {
					this.p = p;
					this.n = normalize(p);
					this.v = vec3(0,10,0);
				}

				void move() {
					p += v * h;

					v.y -= gravity * h;

					if (p.y < 0) {
						p.y = 0;
						v.y = 0;
						v.x -= v.x * friction;
					}
				}
			}
		}

	}

	static this() {
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

		int idx = 12;
		//解像度細かく
		foreach (k; 0..recursionLevel) {

			uint[uint] cache;
			uint getMiddle(uint a, uint b) {
				uint pair = a < b ? (a * 114514 + b) : (b *	114514 + a);
				uint* r = pair in cache;
				if (r != null) {
					return *r;
				}
				auto newVertex = normalize(vertex[a] + vertex[b]);
				vertex ~= newVertex;
				cache[pair] = idx;
				return idx++;
			}
			uint[] indices2;
			foreach (i; 0..indices.length/3) { //各面について

				uint v0 = getMiddle(indices[i*3+0],indices[i*3+1]);
				uint v1 = getMiddle(indices[i*3+1],indices[i*3+2]);
				uint v2 = getMiddle(indices[i*3+2],indices[i*3+0]);

				indices2 ~= [indices[i*3+0], v0, v2];
				indices2 ~= [v0, indices[i*3+1], v1];
				indices2 ~= [v2,v1,indices[i*3+2]];
				indices2 ~= [v0, v1, v2];
			}
			indices = indices2.dup;
		}

		uint[] makePair(uint a, uint b) {
			return a < b ? [a,b] : [b,a];
		}
		//隣を発見
		foreach (i; 0..indices.length/3) {
			auto idx0 = indices[i*3];
			auto idx1 = indices[i*3+1];
			auto idx2 = indices[i*3+2];

			if (pairIndex.canFind(makePair(idx0,idx1)) == false) pairIndex ~= makePair(idx0,idx1);
			if (pairIndex.canFind(makePair(idx1,idx2)) == false) pairIndex ~= makePair(idx1,idx2);
			if (pairIndex.canFind(makePair(idx2,idx0)) == false) pairIndex ~= makePair(idx2,idx0);
		}
	}

	private {
		Particle[] particleList;
		VAO vao;
		VBO vertexVBO;
		VBO normalVBO;
	}

	this()  {
		if (!initFlag) {
			sp = ShaderStore.getShader("NormalShow");


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

			//パーティクル初期化
			foreach (v; vertex) {
				particleList ~= new Particle(v);
			}
		}
	}

	override void Draw() {
		sp.SetUniformMatrix!(4,"mWorld")(GetWorldMatrix.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw(index);

		Move();

		float[] vertexArray;
		foreach (ref p;particleList) {
			vertexArray ~= p.p.array;
		}
		vertexVBO.Update(vertexArray);
	}

	void Move() {
		immutable N = particleList.length;
		foreach (k; 0..100){
			//隣との拘束
			foreach (i; 0..pairIndex.length) {
				auto id0 = pairIndex[i][0], id1 = pairIndex[i][1];
				vec3 d = particleList[id1].p - particleList[id0].p;
				auto len = d.length;
				if (len > 0) d /= len;
				len -= deflen;
				d *= len;
				vec3 v1 = particleList[id1].v - particleList[id0].v;
				vec3 v2 = v1 * velocity_coefficient + d * position_coefficient;
				vec3 dv = (v2 - v1) * 0.5f;
				particleList[id0].v -= dv;
				particleList[id1].v += dv;
			}
		}
		//ちょっとふくらませる
		foreach (i; 0..N) {
			enum force = 10;
			Particle p = particleList[i];
			p.v += p.n * force;
		}

		if (CurrentWindow.isKeyPressed(KeyButton.Z)) {
			foreach (p; particleList) {
				p.v.y -= 5 * (1 - p.p.xz.length);
			}
		}

		foreach (i; 0..N) {
			particleList[i].move();
		}

	}
}