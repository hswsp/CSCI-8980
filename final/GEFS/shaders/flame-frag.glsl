#version 330 core

// Interpolated values from the vertex shaders
in vec2 uv;

// Ouput data
out vec4 color;

uniform sampler2D uDiffuseSampler;
uniform float time;
void main(){
	
	
	// Generate noisy x value
    vec2 n0Uv = vec2(uv.x*1.4 + 0.01, uv.y + time*0.69);
    vec2 n1Uv = vec2(uv.x*0.5 - 0.033, uv.y*2.0 + time*0.12);
    vec2 n2Uv = vec2(uv.x*0.94 + 0.02, uv.y*3.0 + time*0.61);
    float n0 = (texture(uDiffuseSampler, n0Uv).w-0.5)*2.0;
    float n1 = (texture(uDiffuseSampler, n1Uv).w-0.5)*2.0;
    float n2 = (texture(uDiffuseSampler, n2Uv).w-0.5)*2.0;
    float noiseA = clamp(n0 + n1 + n2, -1.0, 1.0);

    // Generate noisy y value
    vec2 n0UvB = vec2(uv.x*0.7 - 0.01, uv.y + time*0.27);
    vec2 n1UvB = vec2(uv.x*0.45 + 0.033, uv.y*1.9 + time*0.61);
    vec2 n2UvB = vec2(uv.x*0.8 - 0.02, uv.y*2.5 + time*0.51);
    float n0B = (texture(uDiffuseSampler, n0UvB).w-0.5)*2.0;
    float n1B = (texture(uDiffuseSampler, n1UvB).w-0.5)*2.0;
    float n2B = (texture(uDiffuseSampler, n2UvB).w-0.5)*2.0;
    float noiseB = clamp(n0B + n1B + n2B, -1.0, 1.0);
	
	vec2 finalNoise = vec2(noiseA, noiseB);
    float perturb = (1.0 - uv.y) * 0.35 + 0.02;
    finalNoise = (finalNoise * perturb) + uv - 0.02;
	
	vec4 texColor = texture(uDiffuseSampler, finalNoise);
    texColor = vec4(texColor.x*2.0, texColor.y*0.9, (texColor.y/texColor.x)*0.2, 1.0);
    finalNoise = clamp(finalNoise, 0.05, 1.0);
    texColor.w = texture(uDiffuseSampler, finalNoise).z*2.0;
    texColor.w = texColor.w*texture(uDiffuseSampler, uv).z;
	texColor.xyz = pow(texColor.xyz,vec3(5.0));
	// Output color = color of the texture at the specified UV
	//vec4 texColor = texture( uDiffuseSampler, uv );
	if(texColor.r < 0.1)
	   discard;	
	color = texColor;
}