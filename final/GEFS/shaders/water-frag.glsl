#version 400 core

in vec2 textureCoords;
in vec4 clipSpace;
out vec4 out_Color;

uniform sampler2D reflectionTexture;
uniform sampler2D refractionTexture;
uniform sampler2D dudvMap;
uniform float moveFactor;
const float waveStrength = 0.01;
void main(void) {

    vec2 ndc = (clipSpace.xy/clipSpace.w)/2.0 + 0.5;
	vec2 refractionTexCoords = vec2(ndc.x,ndc.y);
	vec2 reflectionTexCoords = vec2(ndc.x,-ndc.y);
	
    
	
	vec2 distortion1 = waveStrength * (texture(dudvMap, vec2(textureCoords.x+ moveFactor ,textureCoords.y)).rg*2.0-1.0);//
	vec2 distortion2 = waveStrength * (texture(dudvMap, vec2( -textureCoords.x + moveFactor,textureCoords.y + moveFactor)).rg*2.0-1.0);
	vec2 distortion = distortion1 + distortion2;
	
	reflectionTexCoords += distortion;
	reflectionTexCoords.x = clamp(reflectionTexCoords.x, 0.001, 0.999);
	reflectionTexCoords.y = clamp(reflectionTexCoords.y, -0.999,-0.001);
	
	refractionTexCoords +=distortion;
	refractionTexCoords = clamp(refractionTexCoords,0.001,0.999);
	
	vec4 reflectionColor = texture(reflectionTexture,reflectionTexCoords);
	vec4 refractionColor = texture(refractionTexture,refractionTexCoords);
	
	out_Color = mix(reflectionColor,refractionColor,0.5);
	out_Color = mix(out_Color,vec4(0,0.3,0.5,1.0),0.2);
	

}