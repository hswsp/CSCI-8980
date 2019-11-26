#version 330 core
out vec4 outColor;

in vec3 texCoords;

uniform bool constColor;
uniform vec3 skyColor;

uniform samplerCube skybox;
uniform bool useFog;
vec3 fogColor = 15*vec3(0.8, 0.8,0.8); //
const float FogDensity = 0.5;
void main(){
    if (constColor){
        outColor = vec4(skyColor,1);
    }
    else{
        vec4 envColor = texture(skybox, texCoords);
        outColor = 5*pow(envColor,vec4(5,5,5,1));
    }
    if(useFog)
    {
      float f = exp(-FogDensity*gl_FragCoord.z / gl_FragCoord.w);
      f = clamp( f, 0.0, 1.0 );
      outColor.rgb = mix(fogColor,outColor.rgb,f);
    }
    //outColor = vec4(texCoords,1);
}