module sbylib.shadertemplates.shaderstore;

import sbylib;

class ShaderStore {
	private static ShaderProgram[string] shaderList;

	static void Init() {
		shaderList["NormalShow"] = new ShaderProgram(
													 "
													 uniform mat4 mWorld;
													 uniform mat4 mViewProj;
													 varying vec3 n;

													 void main() {
													 gl_Position = mViewProj * mWorld * gl_Vertex;
													 mat3 m2 = mat3(mWorld[0].xyz,mWorld[1].xyz,mWorld[2].xyz);
													 n = m2 * gl_Normal;
													 }",
													 "
													 varying vec3 n;
													 void main() {
													 gl_FragColor = vec4(n * .5 + .5,1);
													 }",
													 ShaderProgram.InputType.SourceCode);
		shaderList["Check"] = new ShaderProgram(
												"
												uniform mat4 mWorld;
												uniform mat4 mViewProj;
												varying vec3 n;
												varying vec2 tc;

												void main() {
												gl_Position = mViewProj * mWorld * gl_Vertex;
												mat3 m2 = mat3(mWorld[0].xyz,mWorld[1].xyz,mWorld[2].xyz);
												n = m2 * gl_Normal;
												tc = gl_MultiTexCoord0.xy;
												}",
												"
												varying vec3 n;
												varying vec2 tc;
												void main() {
												if ( ( mod(tc.x,0.1) - 0.05) * ( mod(tc.y,0.1) - 0.05) < 0) 
												gl_FragColor = vec4(1,1,1,1);
												else
												gl_FragColor = vec4(0,0,0,1);
												}
												",
												ShaderProgram.InputType.SourceCode);
		//shaderList["Phong"] = new ShaderProgram(
		//                                        "
		//                                        ",
		//                                        "
		//                                        ",
		//                                        ShaderProgram.InputType.SourceCode);
		shaderList["SimpleColor"] = new ShaderProgram(
												"
												uniform mat4 mWorld;
												uniform mat4 mViewProj;

												void main() {
												gl_Position = mViewProj * mWorld * gl_Vertex;
												}",
												"
												uniform vec4 color;
												void main() {
												gl_FragColor = color;
												}
												",
												ShaderProgram.InputType.SourceCode);
		shaderList["DrawRect"] = new ShaderProgram("
												   uniform float cx, cy, width, height, ww, wh;

												   void main() {
												   vec2 v = gl_Vertex.xy;
												   v.x *= width  / ww;
												   v.y *= height / wh;
												   v.x += cx / ww * 2 - 1;
												   v.y += cy / wh * 2 - 1;
												   gl_Position = vec4(v, 0, 1);
												   }
												   ",
												   "
												   uniform vec4 color;
												   void main() {
												   gl_FragColor = vec4(color);
												   }
												   ",
												   ShaderProgram.InputType.SourceCode);
		shaderList["DrawImage"] = new ShaderProgram("uniform float cx, cy, width, height, ww, wh;
													varying vec2 tc;

													void main() {
													vec2 v = gl_Vertex.xy;
													v.x *= width  / ww;
													v.y *= height / wh;
													v.x += cx / ww * 2 - 1;
													v.y += cy / wh * 2 - 1;
													gl_Position = vec4(v, 0, 1);
													tc = gl_Vertex.xy * .5 + .5;
													}
													",
													"
													uniform sampler2D mTexture;
													varying vec2 tc;
													void main() {
													gl_FragColor = texture2D(mTexture, tc);
													}
													",
													ShaderProgram.InputType.SourceCode);
	}

	static ShaderProgram getShader(string key) {
		return shaderList[key];
	}
}