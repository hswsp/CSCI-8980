#version 400 core

in vec2 textureCoords;

out vec4 out_Color;

uniform sampler2D reflectionTexture;
uniform sampler2D refractionTexture;

void main(void) {

    vec4 reflectionColor = texture(reflectionTexture,textureCoords);
	vec4 refractionColor = texture(refractionTexture,textureCoords);
	
	out_Color = mix(reflectionColor,refractionColor,0.5);//vec4(0.0, 0.0, 1.0, 1.0);

}