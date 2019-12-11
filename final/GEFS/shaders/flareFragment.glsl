#version 330

in vec2 pass_textureCoords;

out vec4 out_colour;

uniform sampler2D flareTexture;
uniform float brightness;

void main(void){

    out_colour = texture(flareTexture, pass_textureCoords);
	//if(out_colour.r < 0.01 ||out_colour.g < 0.01 || out_colour.b <0.01)
	//	discard;	
    out_colour.a *= brightness;


}