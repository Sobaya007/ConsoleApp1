module light;

import sbylib;


/*メモ
色について:
gl_FragColor
= material.ambient * light.ambient
+ material.diffuse * light.diffuse * dot(lightVec, normal)
+ material.specular * light.specular * dot(eyeVec, reflect(lightVec, normal) ) ^^ material.power

減衰について:
減衰率attenuation
= 1 / (attenuation0 + dist * attenuation1 + dist^^2 * attenuation2

スポットライトについて:
dot (lightVec, spotDirection) < cos(spotCutoff) => diffuse = true

*/

abstract class Light : Entity {

	this() {
		assert(glIsEnabled(GL_LIGHTING));
		assert(lightID_seed < 8);
		this.lightID = lightID_seed++;
		this.glLightID = lightID_table[lightID];
	}

	@property {
		vec4 Ambient() {
			return ambient;
		}

		void Ambient(vec4 ambient) {
		}
	}

private:
	static int lightID_seed = 0;

	mixin({
		return "static int[] lightID_table = [" ~ 8.iota.map!(to!string).array.reduce!( (a, b)=> a ~  "GL_LIGHT" ~ to!string(b) ~ ",")("")[0..$-1][0] ~ "];";
	}());

	vec4 ambient       = vec4(0, 0, 0, 1); //環境光
	vec4 diffuse       = vec4(1, 1, 1, 1); //拡散光
	vec4 specular      = vec4(1, 1, 1, 1); //反射光
	vec3 spotDirection; //スポットライトの向き
	vec3 attenuation = vec3(1,0,0); //減衰係数。左から0次,1次,2次。
	float spotCutoff; //スポットライトの角度(0～360)
	int lightID; //ID。0～7まで（とここではしておく)
	int glLightID;

}