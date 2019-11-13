#version 150 core

//in vec3 Color;
//in vec3 normal;
//in vec3 pos;
//in vec3 eyePos;
//in vec3 lightDir;

out vec4 out_color;
//const float ambient = .3;
void main() {
    //vec3 N = normalize(normal);
    //vec3 diffuseC = Color*max(dot(lightDir,N),0.0);
    //vec3 ambC = Color*ambient;
    //vec3 reflectDir = reflect(-lightDir,N);
    //vec3 viewDir = normalize(-pos);
    //float spec = max(dot(reflectDir,viewDir),0.0);
   // if (dot(lightDir,N) <= 0.0)
    //   spec = 0;
   // vec3 specC = vec3(.8,.8,.8)*pow(spec,4);
    out_color = vec4(1.0, 0.0, 1.0,1.0);//ambC+diffuseC+specC
 }