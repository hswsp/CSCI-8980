#version 150 core

in vec3 position;

/* 
const int numLights = 3;
vec3 inLightDir[numLights] = vec3[numLights](
     normalize(vec3(-1,-1,-1)),
     normalize(vec3(-.3,.3,-1)),
     normalize(vec3(1,1,-1)));
uniform vec3 inLightCol[numLights] = vec3[numLights](
     1*vec3(1,1,1),
     .5*vec3(1,1,1),
     .6*vec3(1,1,1));
     
/*/

const int maxNumLights = 5;
uniform int numLights;
//x,-z,y - environment map order
uniform vec3 inLightDir[maxNumLights];
uniform vec3 inLightCol[maxNumLights];
//*/
in vec3 inNormal;
in vec2 inTexcoord;
in vec3 inTangent;

out vec3 Color;
out vec3 interpolatedNormal;
out vec3 pos;
out vec3 lightDir[maxNumLights];
out vec3 lightCol[maxNumLights];
out vec2 texcoord;
out vec4 shadowCoord;
out vec3 globalPos;
out mat3 TBN;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
uniform mat3 MV3x3;
uniform mat4 shadowView;
uniform mat4 shadowProj;
uniform vec4 plane;

void main() {

  vec4 worldPosition =  model * vec4(position,1.0);
  gl_ClipDistance[0] = dot(worldPosition,plane);//-1;
  
  gl_Position = proj * view * worldPosition;
  
  globalPos = (model * vec4(position,1.0)).xyz;
  
  vec3 tangent = normalize(inTangent - inNormal * dot(inNormal, inTangent));
  vec3 norm = normalize( MV3x3*inNormal);
  vec3 tang = normalize(MV3x3 *tangent);
  vec3 bitang = normalize(cross(norm, tang));
  TBN = transpose(mat3(
        tang,
        bitang,
        norm
    )); // You can use dot products instead of building this matrix and transposing it. 
	
  pos = (view * model * vec4(position,1.0)).xyz;
  for (int i = 0; i < numLights; i++){
    lightDir[i] = (view * vec4(inLightDir[i],0.0)).xyz; //It's a vector!
    lightCol[i] = inLightCol[i];
  }
  
  vec4 norm4 = transpose(inverse(view*model)) * vec4(inNormal,0.0);
  interpolatedNormal = normalize(norm4.xyz);//vec3(0,0,1);
  texcoord = inTexcoord;

  shadowCoord = shadowProj * shadowView * model * vec4(position,1);
}