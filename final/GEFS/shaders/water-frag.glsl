#version 400 core

in vec2 textureCoords;
in vec4 clipSpace;
in vec3 tocameraVector;
in vec3 fromLightVector;

out vec4 out_Color;


uniform sampler2D reflectionTexture;
uniform sampler2D refractionTexture;
uniform sampler2D dudvMap;
uniform sampler2D normalMap;
uniform sampler2D depthMap;

uniform vec3 lightColour;
uniform float moveFactor;

uniform float nearPlane;
uniform float farPlane;


const float waveStrength = 0.04;
const float shineDamper = 20.0;
const float reflectivity = 0.5;
void main(void) {

    vec2 ndc = (clipSpace.xy/clipSpace.w)/2.0 + 0.5;
	vec2 refractionTexCoords = vec2(ndc.x,ndc.y);
	vec2 reflectionTexCoords = vec2(ndc.x,-ndc.y);
	
	float depth = texture(depthMap,refractionTexCoords).r;
	float floorDostance = 2.0 * nearPlane * farPlane / (farPlane + nearPlane - (2.0 * depth - 1.0) * (farPlane - nearPlane));
	float waterDistance = 2.0 * nearPlane * farPlane / (farPlane + nearPlane - (2.0 * gl_FragCoord.z - 1.0) * (farPlane - nearPlane));
	float waterDepth = floorDostance - waterDistance;
	
    vec2 distortedTexCoords = texture(dudvMap, vec2(textureCoords.x + moveFactor, textureCoords.y)).rg*0.1;
	distortedTexCoords = textureCoords + vec2(distortedTexCoords.x, distortedTexCoords.y+moveFactor);
	vec2 distortion = (texture(dudvMap, distortedTexCoords).rg * 2.0 - 1.0) * waveStrength *clamp(waterDepth/20.0 ,0.0 ,1.0);//
	
	//vec2 distortion1 = waveStrength * (texture(dudvMap, vec2(textureCoords.x+ moveFactor ,textureCoords.y)).rg*2.0-1.0);
	//vec2 distortion2 = waveStrength * (texture(dudvMap, vec2( -textureCoords.x + moveFactor,textureCoords.y + moveFactor)).rg*2.0-1.0);
	//vec2 distortion = distortion1 + distortion2;
	
	reflectionTexCoords += distortion;
	reflectionTexCoords.x = clamp(reflectionTexCoords.x, 0.001, 0.999);
	reflectionTexCoords.y = clamp(reflectionTexCoords.y, -0.999,-0.001);
	
	refractionTexCoords +=distortion;
	refractionTexCoords = clamp(refractionTexCoords,0.001,0.999);
	
	vec4 reflectionColor = texture(reflectionTexture,reflectionTexCoords);
	vec4 refractionColor = texture(refractionTexture,refractionTexCoords);
	
	vec4 nomarMapcolor = texture(normalMap,distortedTexCoords);
	vec3 normal = vec3(nomarMapcolor.r*2.0-1.0,nomarMapcolor.b*3.0,nomarMapcolor.g*2.0-1.0);
	normal = normalize(normal);
	
	vec3 viewVector = normalize(tocameraVector);
	float refravtiveFactor = dot(viewVector,normal);//vec3(0.0,1.0,0.0)
	refravtiveFactor = pow(refravtiveFactor,2.0);
	
	
	
	
	vec3 reflectedLight = reflect(normalize(fromLightVector), normal);
	float specular = max(dot(reflectedLight, viewVector), 0.0);
	specular = pow(specular, shineDamper);
	vec3 specularHighlights = lightColour * specular * reflectivity * clamp(waterDepth/5.0 ,0.0 ,1.0);//
	
	out_Color = mix(reflectionColor,refractionColor,refravtiveFactor);
	out_Color = mix(out_Color,vec4(0,0.3,0.5,1.0),0.2)+ vec4(specularHighlights,0.0) ;
	out_Color.a = clamp(waterDepth/5.0 ,0.0 ,1.0);//
	//out_Color = vec4(vec3(floorDostance),1.0);//vec4(vec3(texture(depthMap,refractionTexCoords).r),1.0);
	//out_Color = vec4(vec3(refravtiveFactor),1.0);

}