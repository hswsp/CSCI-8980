#version 150 core

in vec3 position;
//in vec3 inColor;
//in vec3 inNormal;
//in vec3 inlightDir; 

//out vec3 Color;
//out vec3 normal;
//out vec3 lightDir;
//out vec3 pos;
//out vec3 eyePos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
void main() {
	//Color = inColor;
	//vec4 pos4 = view * model * vec4(position,1.0);
	//pos = pos4.xyz/pos4.w;
	//vec4 norm4 = transpose(inverse(view*model)) * vec4(inNormal,0.0);
	//normal = norm4.xyz;
	//lightDir = (view * vec4(inlightDir,0)).xyz;
	//gl_Position = proj * pos4;

	gl_Position = proj * view * model *vec4(position, 1.0);
}