#version 330

const vec3 waterColour = vec3(0.604, 0.867, 0.851);
const float fresnelReflective = 0.5;

out vec4 out_colour;

in vec4 pass_clipSpaceReal;
in vec3 pass_normal;
in vec3 pass_toCameraVector;

uniform sampler2D reflectionTexture;
uniform sampler2D refractionTexture;
uniform sampler2D depthTexture;

float calculateFresnel(){
	vec3 viewVector = normalize(pass_toCameraVector);
	vec3 normal = normalize(pass_normal);
	float refractiveFactor = dot(viewVector, normal);
	refractiveFactor = pow(refractiveFactor, fresnelReflective);
	return clamp(refractiveFactor, 0.0, 1.0);
}

vec2 clipSpaceToTexCoords(vec4 clipSpace){
	vec2 ndc = (clipSpace.xy / clipSpace.w);
	vec2 texCoords = ndc / 2.0 + 0.5;
	return texCoords;
}

void main(void){

	vec2 texCoordsReal = clipSpaceToTexCoords(pass_clipSpaceReal);
	
	vec2 refractionTexCoords = texCoordsReal;
	vec2 reflectionTexCoords = vec2(texCoordsReal.x, 1.0 - texCoordsReal.y);
	
	vec3 refractColour = texture(refractionTexture, refractionTexCoords).rgb;
	vec3 reflectColour = texture(reflectionTexture, reflectionTexCoords).rgb;
	
	vec3 finalColour = mix(reflectColour, refractColour, calculateFresnel());
	
	out_colour = vec4(finalColour, 1.0);

}