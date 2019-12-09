#version 330 core

layout (location = 0) out vec4 outColor;
layout (location = 1) out vec4 brightColor;

const int maxNumLights = 5; 

uniform int numLights;

in vec3 interpolatedNormal; //TODO: Just call this normal?
in vec3 pos;
in vec3 lightDir[maxNumLights];
in vec3 lightCol[maxNumLights];
in mat3 TBN;
//TODO: Support point lights

uniform vec3 modelColor;
uniform vec3 materialColor;
in vec2 texcoord;

uniform float metallic; //0-1  (When Metalic is 1, we ignore IOR)
uniform float roughness; //~.1-1
uniform float ior; //1.3-5? (stick ~1.3-1.5 unless gemstone or so)

uniform bool xxx;

uniform sampler2D colorTexture;
uniform sampler2D NormalTextureSampler;
uniform vec2 textureScaleing;
uniform vec3 emissive;

uniform vec3 ambientLight;

uniform sampler2D shadowMap;
in vec4 shadowCoord;
uniform bool useShadow;
uniform int pcfSize;
uniform float shadowBias;

uniform int useTexture;
uniform int useNormalMap;

uniform vec3 skyColor;
uniform bool useSkyColor;
uniform mat4 invView; //inverse of view matrix
uniform samplerCube skybox;
uniform mat4 rotSkybox;
//uniform vec3 cameraPos;
uniform float reflectiveness;

//Cook-torrance basics with code
//http://filmicworlds.com/blog/optimizing-ggx-shaders-with-dotlh/
//http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx


//float G1V(float dotNV, float k){return 1.f/ (dotNV*(1-k)+k);}

float G1V(float dotNV, float k){return dotNV/ (dotNV*(1-k)+k);}  //Maybe better?

/****************fog shader********************************************/
uniform bool useFog;
uniform bool UseFlame;

vec3 fogColor = 10* ambientLight; //vec3(0.5, 0.5,0.5) vec3(0,10,0)
const float FogDensity = 0.07;
const float gradient = 1.5;

uniform bool useDissolve;
uniform sampler2D dataTexture;
uniform float timeValue;


uniform sampler2D uDiffuseSampler;
uniform float time ;
uniform vec2 resolution;

vec3 GGXSpec(vec3 N, vec3 V, vec3 L, float rough, vec3 F0){
  float alpha = rough*rough;

  vec3 H = normalize(V+L);

  float dotNL = clamp(dot(N,L),0.0,1.0);
  float dotNV = clamp(dot(N,V),0.0,1.0);
  float dotNH = clamp(dot(N,H),0.0,1.0);
  float dotLH = clamp(dot(L,H),0.0,1.0);
  float dotVH = clamp(dot(V,H),0.0,1.0);

  //D - Geometry distribution term (Microfaset distribution)
  //How focused the specular reflection is:
  // More roughness, less focused specular (in limit uniform)
  // Less roughness, more focused highlight 
  // Approximate idea: same amount of light gets reflected back, on smooth surfaces only a few
  // parts of the object will be pointing the right direction to reflect, but all nearby points reflect
  // strongly. On rough surfaces, a larger portion of the object will reflect back, but the reflection
  // is weaker (http://www.codinglabs.net/public/contents/article_physically_based_rendering_cook_torrance/images/ggx_distribution.jpg)
  float alphaSqr = alpha*alpha;
  float pi = 3.141592f;
  float denom = dotNH * dotNH * (alphaSqr - 1.0) + 1.0;
  float D = alphaSqr / (pi * denom * denom);

  //F - Fresnel
  //Response from light depends on angle (Schlick approximation)
  float dotLH5 = pow(1.0f - dotLH,5);
  vec3 F = F0 + (1.0 - F0)*(dotLH5);

  //G - Visibility term ... supposed to capture how microfacets shadow each other
  //Lights from smooth surfaces get brighter at grazing angles, but not rough surfaces (maybe ???)
  // This is due to micofacets shadowing each other
  float k = alpha*.5;
  float vis = G1V(dotNL,k)*G1V(dotNV,k); //Shlick-style approximation
  //vis = dotNL*dotNV; //Implicit ... fast to compute, but doesn't depend on roughness =/
  //vis = min(1.f,min(2*dotNH*dotNV/dotVH,2*dotNH*dotNL/dotVH)); //Original cook-torance formulation
  //Some hack I found somewhere online...
    //float k2 = k*k;
    //float invk2 = 1.0f-k2;
    //vis = 1/(dotLH*dotLH*invk2+k2); 

  if (dotNL <= 0) vis = 0;

  float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0);
  vec3 specular = vec3( D * F * vis);  //also a dotNL term here? I'm not sure
  return specular;
}

vec3 flame()
{
   vec2 pos = -1. + 2.*gl_FragCoord.xy / resolution.xy;
   pos *= vec2(resolution.x / resolution.y, 1.) * 3.;
   
   // Flame jitter
   if(pos.y>-2.*4.2)
   {
      for(float baud = 1.; baud < 9.; baud += 1.)
      {
         pos.y += 0.2*sin(4.20*time/(1.+baud))/(1.+baud);
         pos.x += 0.1*cos(pos.y/4.20+2.40*time/(1.+baud))/(1.+baud);
      }
      pos.y += 0.04*fract(sin(time*60.));
   }
   
   // outer fire
   vec3 color = vec3(0.,0.,0.);
   float p =.004;
   float y = -pow(abs(pos.x), 4.2)/p;   // shape of the outer fire，pos.x<0 will be cut
   float dir = abs(pos.y - y)*sin(.3);  // size of the outer fire
   //float dir = abs(pos.y - y)*(0.01*sin(time)+0.07);
   if(dir < 0.7)
   {
      color.rg += smoothstep(0.,1.,.75-dir);   // color of the outer fire
      color.g /=2.4;                           // substract some green
   }
   color *= (0.2 + abs(pos.y/4.2 + 4.2)/4.2);  // increase contrast
   color += pow(color.r, 1.1);                 // add red
   color *= cos(-0.5+pos.y*0.4);               // hidden color of the bottom
   
   //inner
   pos.y += 1.5;
   vec3 dolor = vec3(0.,0.,0.0);
   y = -pow(abs(pos.x), 4.2)/(4.2*p)*4.2;   // shape of the inner fire，the power should be close to that of outer fire
   dir = abs(pos.y - y)*sin(1.1);           // scale of inner fire
   if(dir < 0.7)
   {
      dolor.bg += smoothstep(0., 1., .75-dir);// change the color of inner fire
      dolor.g /=2.4;
   }
   dolor *= (0.2 + abs((pos.y/4.2+4.2))/4.2);
   dolor += pow(color.b,1.1);                 // add some blue
   dolor *= cos(-0.6+pos.y*0.4);
   //dolor.rgb -= pow(length(dolor)/16., 0.5);
   
   color = (color+dolor)/2.;
   return color;
}


//=======================================================================================
float DefiniteIntegral (in float x, in float amplitude, in float frequency, in float motionFactor)
{
    // Fog density on an axis:
    // (1 + sin(x*F)) * A
    //
    // indefinite integral:
    // (x - cos(F * x)/F) * A
    //
    // ... plus a constant (but when subtracting, the constant disappears)
    //
    x += time * motionFactor;
    return (x - cos(frequency * x)/ frequency) * amplitude;
}
 
//=======================================================================================
float AreaUnderCurveUnitLength (in float a, in float b, in float amplitude, in float frequency, in float motionFactor)
{
    // we calculate the definite integral at a and b and get the area under the curve
    // but we are only doing it on one axis, so the "width" of our area bounding shape is
    // not correct.  So, we divide it by the length from a to b so that the area is as
    // if the length is 1 (normalized... also this has the effect of making sure it's positive
    // so it works from left OR right viewing).  The caller can then multiply the shape
    // by the actual length of the ray in the fog to "stretch" it across the ray like it
    // really is.
    return (DefiniteIntegral(a, amplitude, frequency, motionFactor) - DefiniteIntegral(b, amplitude, frequency, motionFactor)) / (a - b);
}
 
//=======================================================================================
float FogAmount (in vec3 src, in vec3 dest)
{
    float len = length(dest - src);
     
    // calculate base fog amount (constant density over distance)   
    float amount = len * 0.1;
     
    // calculate definite integrals across axes to get moving fog adjustments
    float adjust = 0.0;
    adjust += AreaUnderCurveUnitLength(dest.x, src.x, 0.01, 0.6, 2.0);
    adjust += AreaUnderCurveUnitLength(dest.y, src.y, 0.01, 1.2, 1.4);
    adjust += AreaUnderCurveUnitLength(dest.z, src.z, 0.01, 0.9, 2.2);
    adjust *= len;
     
    // make sure and not go over 1 for fog amount!
    return min(amount+adjust, 1.0);
}
void main() {
  vec3 color;
  if (useTexture == 0)
    color = materialColor;
  else
    color = materialColor*texture(colorTexture, texcoord*textureScaleing).rgb;
  vec3 normal = normalize(interpolatedNormal);
  vec3 ambC = color*ambientLight;
  vec3 oColor = ambC+emissive;
  if(useNormalMap>0)
  {
     vec3 TextureNormal_tangentspace = normalize(texture( NormalTextureSampler, texcoord*textureScaleing ).rgb*2.0 - 1.0); 
	 normal = TextureNormal_tangentspace;//TBN*
	 
  }
  

  for (int i = 0; i < numLights; i++){
    float shadow = 0;
    float bias = shadowBias * max(2 * (1.0 - dot(normal, lightDir[i])),1); // const float bias = 0.01; //
    if (i == 0 && useShadow){ //TODO: Only the first light can have a shadow
      vec3 projCoords = vec3(shadowCoord.xyz/shadowCoord.w);
      projCoords = projCoords * 0.5 + 0.5; 
      float currentDepth = projCoords.z;
      //* //PCF:
      shadow = 0.0;
      vec2 texelSize = 1.0 / textureSize(shadowMap, 0);
      for(int x = -pcfSize; x <= pcfSize; ++x){
        for(int y = -pcfSize; y <= pcfSize; ++y){
          float pcfDepth = texture(shadowMap, projCoords.xy + vec2(x, y) * texelSize).r; 
          shadow += currentDepth> pcfDepth + bias ? 0.95 : 0.0;   //Hack to keep some ambient in shadow regions
        }    
      }
      shadow /= (2*pcfSize+1)*(2*pcfSize+1);
      /*/ //Binary Shadow Map:
      float closestDepth = texture(shadowMap, projCoords.xy).r;
      shadow = currentDepth > closestDepth+bias ? 1.0 : 0.0;
      //*/
    }

    vec3 specC;
    vec3 lDir = lightDir[i];
	if(useNormalMap>0)
    {
	   lDir = TBN*lDir;
    }
    vec3 diffuseC = (1-metallic)*color*max(dot(-lDir,normal),0.0); //This is a Hack? Is it a good idea? Is it true metals have no diffuse color?
    vec3 viewDir = normalize(-pos); //We know the eye is at (0,0)!
	if(useNormalMap>0)
	{
	  viewDir = TBN*viewDir;
	}
    vec3 reflectDir = reflect(viewDir,normal);
    
    /*float spec = max(dot(reflectDir,lDir),0.0);
    if (dot(-lDir,normal) <= 0.0) spec = 0; //No specularity if light is behind object
    float m = 2*clamp(.6-roughness,0.0,1.0);
      specC = m*.8*vec3(1.0,1.0,1.0)*pow(spec,80*m/(ior*ior));
    if (m < .01) specC = vec3(0);*/

    vec3 iorVec = ior*vec3(1,1,1);

    vec3 F0 = abs ((1.0 - iorVec) / (1.0 + iorVec));
    F0 = F0 * F0;
    F0 = mix(F0,color,metallic);
    
    vec3 envColor = skyColor;
    if (!useSkyColor){
      vec3 eyeDir = normalize(pos.xyz); 
      vec3 RefVec = reflect(eyeDir.xyz, normal);
      RefVec = (rotSkybox*invView*vec4(RefVec,0)).xyz;
      envColor = texture(skybox, RefVec).rgb; 
      envColor = 5*pow(envColor,vec3(5,5,5)); //Hack to turn a non-HDR texture into an HDR one
    }    
    specC = lightCol[i]*GGXSpec(normal,viewDir,-lDir,roughness,F0);

    float ref = reflectiveness; //A simple reflectivness hack, really this should be part of sampling the BRDF
    specC += ref*envColor;

    oColor += (1-shadow)*(lightCol[i]*diffuseC+specC);
  }
  if (xxx) 
    oColor = oColor.gbr; //Just to demonstrate how to use the boolean for debugging
  outColor = vec4(modelColor*oColor, 1.0);
  //if(useNormalMap>0)
   // outColor = vec4(transpose(TBN)*texture(NormalTextureSampler, texcoord).rgb,1.0); //vec4(transpose(TBN)*vec3(0,0,1),1.0);
  /******************fog *************************/
  
  if(useFog)
  {
      float f = exp(-pow(FogDensity*length(pos),gradient));
      //outcolor = vec4(f*outcolor.rgb+3*ambientlight*length(pos),1);
      f = clamp( f, 0.0, 1.0 );
      //vec3 dest = vec3(0,0,0);
      //float f = 1 - FogAmount (pos, dest);
      outColor.rgb = mix(fogColor,outColor.rgb,f);
  }

  if(useDissolve && texcoord.x>-.9)
  {
    float textValue = texture(dataTexture,texcoord).r;
    float diff = timeValue - textValue;
    vec3 glowColor = vec3(0,0,0);
    if(diff<.05)
    {
      glowColor = mix(vec3(20,5,5),vec3(15,0,0),diff/.2);
    }
    if(diff<=0)
    {
      glowColor = vec3(20,0,0);
      discard;
    }
    outColor.rgb+=glowColor;
      
  }
  
  // Flame
  if(UseFlame)
  {
    color = flame();
    outColor.rgb += 15*color;
  }
  
 
  float brightness = dot(oColor, vec3(0.3, 0.6, 0.1));
  brightColor = outColor;
  if(brightness < 1)
      brightColor = vec4(0.0, 0.0, 0.0, 1.0);
}

