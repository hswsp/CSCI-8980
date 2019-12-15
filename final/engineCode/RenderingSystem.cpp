#include "GPU-Includes.h"
#include "RenderingSystem.h"
#include "RenderingCore.h"

#include "Bloom.h"
#include "Skybox.h"
#include "Shadows.h"
#include "CollisionSystem.h"
#include "Shader.h"
#include <external/loguru.hpp>
#include <external/stb_image.h>
#include <iostream>
#include <math.h>
#undef near
#undef far
#define FLARETEXTURENUM 9 
using std::vector;
using namespace std;
extern bool useFog;
extern bool useFlame;
extern bool useDissolve;
extern int targetScreenWidth;
extern int targetScreenHeight;
extern float cameraFar;
extern float cameraNear;
//#define GL_CLAMP_TO_EDGE 0x812F

GLuint tex[1000];
GLuint normalTex[1000];

GLuint dudvTexture, normalMapTexture;

bool xxx; //Just an unspecified bool that gets passed to shader for debugging

int sphereVerts; //Number of verts in the colliders spheres

int totalTriangles = 0;

GLint uniColorID, uniEmissiveID, uniUseTextureID, modelColorID,useNormalMapID;
GLint metallicID, roughnessID, iorID, reflectivenessID;
GLint uniModelMatrix, colorTextureID,nomalMapID,dataTextureID, flameTextureID, texScaleID, biasID, pcfID, TimeValueID;
GLint xxxID, useDissolveID,useFogID, timeID, resolutionID, useFlameID, ModelView3x3MatrixID;

GLuint colliderVAO; //Build a Vertex Array Object for the collider
GLuint planeID, reflectionTextureID, refractionTextureID;
float waterquad[] = { -1, -1, -1, 1, 1, -1, 1, -1, -1, 1, 1, 1 };


GLuint flaretex[FLARETEXTURENUM];
GLuint flametex;
void drawGeometry(Model& model, int matID, glm::mat4 view, glm::mat4 transform = glm::mat4(), float cameraDist = 0, glm::vec2 textureWrap=glm::vec2(1,1), glm::vec3 modelColor=glm::vec3(1,1,1));

void drawGeometry(Model& model, int materialID, glm::mat4 view, glm::mat4 transform, float cameraDist, glm::vec2 textureWrap, glm::vec3 modelColor){
	
	//if (model.materialID >= 0) material = materials[model.materialID];
	
	Material material;
	if (materialID < 0){
		materialID = model.materialID; 
	} 
	if (materialID >= 0){
		material = materials[materialID]; // Maybe should be a pointer
	}
	//printf("Using material %d - %s\n", model.materialID,material.name.c_str());

	transform *= model.transform;
	modelColor *= model.modelColor;
	//textureWrap *= model.textureWrap; //TODO: Where best to apply textureWrap transform?
	
	if (cameraDist > model.lodDist && model.lodChild){
		drawGeometry(*model.lodChild, materialID, view, transform, cameraDist,textureWrap, modelColor);
		return;
	}

	if (model.selector >= 0 && model.selector < model.numChildren){
		drawGeometry(*model.childModel[model.selector], materialID, view, transform, cameraDist, textureWrap, modelColor);
	}
	else{
		for (int i = 0; i < model.numChildren; i++){
			drawGeometry(*model.childModel[i], materialID, view, transform, cameraDist, textureWrap, modelColor);
		}
	}
	if (!model.modelData) return;


	transform *= model.modelOffset;
	textureWrap *= model.textureWrap; //TODO: Should textureWrap stack like this?

	glUniformMatrix4fv(uniModelMatrix, 1, GL_FALSE, glm::value_ptr(transform));
	glm::mat4 ModelViewMatrix = view * transform;
	glm::mat3 ModelView3x3Matrix = glm::mat3(ModelViewMatrix); // Take the upper-left part of ModelViewMatrix
	glUniformMatrix3fv(ModelView3x3MatrixID, 1, GL_FALSE, &ModelView3x3Matrix[0][0]);

	glUniform1i(uniUseTextureID, material.textureID >= 0); //textureID of -1 --> no texture
	glUniform1i(useNormalMapID, model.normalMapID >= 0);
	if (material.textureID >= 0){
		glActiveTexture(GL_TEXTURE0);  //Set texture 0 as active texture
		glBindTexture(GL_TEXTURE_2D, tex[material.textureID]); //Load bound texture
		glUniform1i(colorTextureID, 0); //Use the texture we just loaded (texture 0) as material color
		glUniform2fv(texScaleID, 1, glm::value_ptr(textureWrap));
	}

	if (model.normalMapID >= 0) {
		glActiveTexture(GL_TEXTURE6);  //Set texture 0 as active texture
		glBindTexture(GL_TEXTURE_2D, normalTex[model.normalMapID]); //Load bound texture
		glUniform1i(nomalMapID, 6); //Use the texture we just loaded (texture 0) as material color
	}

	
	glActiveTexture(GL_TEXTURE4);  //Set texture 4 as active texture
	glBindTexture(GL_TEXTURE_2D, tex[999]); //Load bound texture
	glUniform1i(dataTextureID, 4); //Use the texture we just loaded (texture 0) as material color
	static float t = 1;
	static bool decrease = true;
	glUniform1f(TimeValueID, t);
	//cout << model.IsDissolve << " " << model.finishDisslve << endl;
	if (!useDissolve )//&& !model.IsDissolve
	{
		t = 1;
	}
	else
	{
		if (decrease)
		{
			t *= (1 - 5e-5);
			if (t <= 0.05)
			{
				//std::cout << "t is :" << t <<std::endl;
				decrease = false;
				model.finishDisslve = true;
				
			}

		}
		else
		{
			model.IsDissolve = false;
			t *= (1 + 5e-5);
			if (t >= 1)
				decrease = true;
		}
	}
	

	glUniform1i(xxxID, xxx);
	glUniform1i(useDissolveID, useDissolve);
	glUniform1i(useFogID, useFog);
	glUniform1i(useFlameID, useFlame);

	glActiveTexture(GL_TEXTURE3);  //Set texture 0 as active texture
	glBindTexture(GL_TEXTURE_2D, tex[998]); //Load bound texture
	glUniform1i(flameTextureID, 3); //Use the texture we just loaded (texture 0) as material color
	long long curTime_dt = SDL_GetTicks(); //TODO: is this really long long?
	glUniform1f(timeID, curTime_dt/1000.0f);


	glUniform3fv(modelColorID, 1, glm::value_ptr(modelColor*model.modelColor)); //multiply parent's color by your own

	glUniform1f(metallicID, material.metallic); 
	glUniform1f(roughnessID, material.roughness); 
	glUniform1f(iorID, material.ior);
	glUniform1f(reflectivenessID, material.reflectiveness);
	glUniform3fv(uniColorID, 1, glm::value_ptr(material.col));
	glUniform3fv(uniEmissiveID, 1, glm::value_ptr(material.emissive));

	//printf("start/end %d %d\n",model.startVertex, model.numVerts);
	totalTriangles += model.numVerts/3; //3 verts to a triangle
	/*if(model.numVerts>0)
		printf("draw models: '%s' (Material ID %d) to material %d \n", model.name.c_str(), model.normalMapID, material.textureID);*/
	glDrawArrays(GL_TRIANGLES, model.startVertex, model.numVerts); //(Primitive Type, Start Vertex, End Vertex) //Draw only 1st object
}

void drawColliderGeometry(){ //, Material material //TODO: Take in a material for the colliders
	//printf("Drawing %d Colliders\n",collisionModels.size());
	//printf("Material ID: %d\n", material);

	glBindVertexArray(colliderVAO);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

	glm::vec3 baseColor = glm::vec3(1,1,1);
	glm::vec3 modelColor = glm::vec3(1,0,0);

	glUniform1i(uniUseTextureID, -1); //textureID of -1 --> no texture

	glUniform1i(xxxID, xxx);

	glUniform3fv(modelColorID, 1, glm::value_ptr(baseColor)); //multiply parent's color by your own

	glUniform1f(metallicID, 0); 
	glUniform1f(roughnessID, 0); 
	glUniform1f(iorID, 1);
	glUniform3fv(uniColorID, 1, glm::value_ptr(modelColor));
	glUniform3fv(uniEmissiveID, 1, glm::value_ptr(modelColor));
	
	//TODO: Maybe loop through each layer and color by layer instead?
	for (size_t i = 0; i < collisionModels.size(); i++){
		Collider* c = models[collisionModels[i]].collider;
		if (c == nullptr) continue;
		//printf("Drawing at pos %f %f %f, radius = %f\n",c->globalPos[0],c->globalPos[1],c->globalPos[2],c->r);

		glm::mat4 colliderTans = glm::translate(glm::mat4(), c->globalPos);
		colliderTans = glm::scale(colliderTans, glm::vec3(c->r,c->r,c->r));
		
		glUniformMatrix4fv(uniModelMatrix, 1, GL_FALSE, glm::value_ptr(colliderTans));
		glDrawArrays(GL_TRIANGLES, 0, sphereVerts/3); //(Primitive Type, Start Vertex, End Vertex) //Draw only 1st object
	}

	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
}


//TODO: When is the best time to call this? This loads all textures, should we call it per-texture instead?
void loadTexturesToGPU(){
  int width, height, nrChannels;
  stbi_set_flip_vertically_on_load(true);
  for (int i = 0; i < numTextures; i++){

    LOG_F(1,"Loading Texture %s",textures[i].c_str());
    unsigned char *pixelData = stbi_load(textures[i].c_str(), &width, &height, &nrChannels, STBI_rgb);
		CHECK_NOTNULL_F(pixelData,"Fail to load model texture: %s",textures[i].c_str()); //TODO: Is there some way to get the error from STB image?
    
		//Load the texture into memory
    glGenTextures(1, &tex[i]);
		glBindTexture(GL_TEXTURE_2D, tex[i]);
		glTexStorage2D(GL_TEXTURE_2D, 2, GL_RGBA8, width, height); //Mipmap levels
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
		glGenerateMipmap(GL_TEXTURE_2D);
    
    //What to do outside 0-1 range
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    
    stbi_image_free(pixelData);	
  }
  //normal map
  for (int i = 0; i < numnormalMaps; i++) {

	  LOG_F(1, "Loading Texture %s", normalMaps[i].c_str());
	  unsigned char *pixelData = stbi_load(normalMaps[i].c_str(), &width, &height, &nrChannels, STBI_rgb);
	  CHECK_NOTNULL_F(pixelData, "Fail to load model normal maps: %s", normalMaps[i].c_str()); //TODO: Is there some way to get the error from STB image?

	  //Load the texture into memory
	  glGenTextures(1, &normalTex[i]);
	  glBindTexture(GL_TEXTURE_2D, normalTex[i]);
	  glTexStorage2D(GL_TEXTURE_2D, 2, GL_RGBA8, width, height); //Mipmap levels
	  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
	  glGenerateMipmap(GL_TEXTURE_2D);

	  //What to do outside 0-1 range
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); //TODO: Does this look better? I'm not sure
	  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	  stbi_image_free(pixelData);
  }

  // glare
  for (int i = 0; i < FLARETEXTURENUM; i++) {
	  string textureName = string("./textures/LensFlare/") + string("tex") + std::to_string(i+1) +string(".png");
	  LOG_F(1, "Loading Texture %s", textureName.c_str());
	  unsigned char *pixelData = stbi_load(textureName.c_str(), &width, &height, &nrChannels, STBI_rgb);
	  CHECK_NOTNULL_F(pixelData, "Fail to load model texture: %s", textureName.c_str()); //TODO: Is there some way to get the error from STB image?

	  //Load the texture into memory
	  glGenTextures(1, &flaretex[i]);
	  glBindTexture(GL_TEXTURE_2D, flaretex[i]);
	  glTexStorage2D(GL_TEXTURE_2D, 2, GL_RGBA8, width, height); //Mipmap levels
	  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
	  glGenerateMipmap(GL_TEXTURE_2D);

	  //What to do outside 0-1 range
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); //TODO: Does this look better? I'm not sure
	  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	  stbi_image_free(pixelData);
  }

  string normalMapImg = string("./textures/normal.png");
  LOG_F(1, "Loading Texture %s", normalMapImg.c_str());
  unsigned char *pixelData = stbi_load(normalMapImg.c_str(), &width, &height, &nrChannels, STBI_rgb);
  CHECK_NOTNULL_F(pixelData, "Fail to load model texture: %s", normalMapImg.c_str()); //TODO: Is there some way to get the error from STB image?

  //Load the texture into memory
  glGenTextures(1, &normalMapTexture);
  glBindTexture(GL_TEXTURE_2D, normalMapTexture);
  glTexStorage2D(GL_TEXTURE_2D, 2, GL_RGBA8, width, height); //Mipmap levels
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
  glGenerateMipmap(GL_TEXTURE_2D);

  //What to do outside 0-1 range
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  stbi_image_free(pixelData);

  
  string dudvMapImg = string("./textures/waterDUDV.png");
  LOG_F(1, "Loading Texture %s", dudvMapImg.c_str());
  pixelData = stbi_load(dudvMapImg.c_str(), &width, &height, &nrChannels, STBI_rgb);
  CHECK_NOTNULL_F(pixelData, "Fail to load texture: %s", dudvMapImg.c_str()); //TODO: Is there some way to get the error from STB image?

  //Load the texture into memory
  glGenTextures(1, &dudvTexture);
  glBindTexture(GL_TEXTURE_2D, dudvTexture);
  glTexStorage2D(GL_TEXTURE_2D, 2, GL_RGBA8, width, height); //Mipmap levels
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
  glGenerateMipmap(GL_TEXTURE_2D);

  //What to do outside 0-1 range
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, -0.4f);
  stbi_image_free(pixelData);

  string flameImg = string("./textures/Flame/flame.png");
  LOG_F(1, "Loading Texture %s", flameImg.c_str());
  pixelData = stbi_load(flameImg.c_str(), &width, &height, &nrChannels, STBI_rgb);
  CHECK_NOTNULL_F(pixelData, "Fail to load texture: %s", flameImg.c_str()); //TODO: Is there some way to get the error from STB image?

  //Load the texture into memory
  glGenTextures(1, &flametex);
  glBindTexture(GL_TEXTURE_2D, flametex);
  glTexStorage2D(GL_TEXTURE_2D, 2, GL_RGBA8, width, height); //Mipmap levels
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
  glGenerateMipmap(GL_TEXTURE_2D);

  //What to do outside 0-1 range
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  stbi_image_free(pixelData);


}


//------------ HDR ------------------
GLuint fboHDR; //floating point FBO for HDR rendering (two render outputs, base color and bloom)
GLuint baseTex, brightText; //Textures which are bound to the bloom FBOs
unsigned int pingpongFBO[2];
unsigned int pingpongColorbuffers[2];

void initHDRBuffers(){
	glGenFramebuffers(1, &fboHDR);
	glBindFramebuffer(GL_FRAMEBUFFER, fboHDR);
	//Specify which color attachments we'll use (of this framebuffer) for rendering (both regular and bright pixels) 
	unsigned int attachments[2] = { GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1 };
	glDrawBuffers(2, attachments);
	//fboHDR = createFrameBuffer();
	glGenTextures(1, &baseTex);
	glBindTexture(GL_TEXTURE_2D, baseTex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, screenWidth, screenHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, baseTex, 0);
	
	glGenTextures(1, &brightText);
	glBindTexture(GL_TEXTURE_2D, brightText);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, screenWidth, screenHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, brightText, 0);

	// create and attach depth buffer (renderbuffer)
	unsigned int rboDepth;
	glGenRenderbuffers(1, &rboDepth);
	glBindRenderbuffer(GL_RENDERBUFFER, rboDepth);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, screenWidth, screenHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepth);
	
	// finally check if framebuffer is complete
	CHECK_F(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, "Framebuffer not complete!");
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	
	// A pair of ping-pong framebuffers for extended blurring
	glGenFramebuffers(2, pingpongFBO);
	glGenTextures(2, pingpongColorbuffers);
	for (unsigned int i = 0; i < 2; i++){
			glBindFramebuffer(GL_FRAMEBUFFER, pingpongFBO[i]);
			glBindTexture(GL_TEXTURE_2D, pingpongColorbuffers[i]);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, screenWidth, screenHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); //why clamp?
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, pingpongColorbuffers[i], 0);
	}

	glBindFramebuffer(GL_FRAMEBUFFER,0); //Return to normal rendering
}


//------------ PBR Shader ---------
Shader PBRShader;

GLint posAttrib, texAttrib, normAttrib, tangentAttrib;
GLint uniView,uniInvView, uniProj;
GLuint modelsVAO, modelsVBO, tangentbuffer;

void initPBRShading(){
	PBRShader = Shader("shaders/vertexTex.glsl", "shaders/fragmentTex.glsl");
	PBRShader.init();

	//Build a Vertex Array Object. This stores the VBO to shader attribute mappings
	glGenVertexArrays(1, &modelsVAO); //Create a VAO
	glBindVertexArray(modelsVAO); //Bind the above created VAO to the current context

	//We'll store all our models in one VBO //TODO: We should compare to 1 VBO/model?
	glGenBuffers(1, &modelsVBO); 
	glGenBuffers(1, &tangentbuffer);
	loadAllModelsTo1VBO(modelsVBO);

	
	glBindBuffer(GL_ARRAY_BUFFER, tangentbuffer);
	int vextexCount = 0;
	
	for (int i = 0; i < numModels; i++) {
		vextexCount += models[i].numVerts;
	}
	int totalVertexCount = vextexCount;
	float* allModelData = new float[vextexCount * 3];
	copy(models[0].TangentData, models[0].TangentData + models[0].numVerts * 3, allModelData);
	
	for (int i = 0; i < numModels; i++) {
		copy(models[i].TangentData, models[i].TangentData + models[i].numVerts * 3, allModelData + models[i].startVertex * 3);
		/*for (int j = 0; j < models[i].numVerts * 3; ++j)
		{
			std::cout << j<<" "<<models[i].TangentData[j] << std::endl;
		}*/
	}
	
	glBufferData(GL_ARRAY_BUFFER, totalVertexCount * 3 * sizeof(float), allModelData, GL_STATIC_DRAW); //upload model data to the VBO
	
	//Tell OpenGL how to set fragment shader input 
	posAttrib = glGetAttribLocation(PBRShader.ID, "position");
	glEnableVertexAttribArray(posAttrib);
	//Binds to VBO current GL_ARRAY_BUFFER 
	glBindBuffer(GL_ARRAY_BUFFER, modelsVBO);
	glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), 0);
	  //Attribute, vals/attrib., type, normalized?, stride, offset

	
	//GLint colAttrib = glGetAttribLocation(phongShader, "inColor");
	//glVertexAttribPointer(colAttrib, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(3*sizeof(float)));
	//glEnableVertexAttribArray(colAttrib);
	
	texAttrib = glGetAttribLocation(PBRShader.ID, "inTexcoord");
	glEnableVertexAttribArray(texAttrib);
	//Binds to VBO current GL_ARRAY_BUFFER 
	glBindBuffer(GL_ARRAY_BUFFER, modelsVBO);
	glVertexAttribPointer(texAttrib, 2, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(3*sizeof(float)));

	
	normAttrib = glGetAttribLocation(PBRShader.ID, "inNormal");
	glEnableVertexAttribArray(normAttrib);
	//Binds to VBO current GL_ARRAY_BUFFER 
	glBindBuffer(GL_ARRAY_BUFFER, modelsVBO);
	glVertexAttribPointer(normAttrib, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(5*sizeof(float)));
	


	
	//Tell OpenGL how to set fragment shader input 
	tangentAttrib = glGetAttribLocation(PBRShader.ID, "inTangent");
	glEnableVertexAttribArray(tangentAttrib);
	//Binds to VBO current GL_ARRAY_BUFFER 
	glBindBuffer(GL_ARRAY_BUFFER, tangentbuffer);
	glVertexAttribPointer(tangentAttrib, 3, GL_FLOAT, GL_TRUE, 3 * sizeof(float), 0);
	//Attribute, vals/attrib., type, normalized?, stride, offset
	



	uniView = glGetUniformLocation(PBRShader.ID, "view");
	uniInvView  = glGetUniformLocation(PBRShader.ID, "invView"); //inverse of view matrix
	uniProj = glGetUniformLocation(PBRShader.ID, "proj");
	ModelView3x3MatrixID = glGetUniformLocation(PBRShader.ID, "MV3x3");

	uniColorID = glGetUniformLocation(PBRShader.ID, "materialColor");
    uniEmissiveID = glGetUniformLocation(PBRShader.ID, "emissive");
    uniUseTextureID = glGetUniformLocation(PBRShader.ID, "useTexture");
	modelColorID = glGetUniformLocation(PBRShader.ID, "modelColor");
	metallicID = glGetUniformLocation(PBRShader.ID, "metallic");
	roughnessID = glGetUniformLocation(PBRShader.ID, "roughness");
	biasID = glGetUniformLocation(PBRShader.ID, "shadowBias");
	pcfID = glGetUniformLocation(PBRShader.ID, "pcfSize");
	iorID = glGetUniformLocation(PBRShader.ID, "ior");
	reflectivenessID = glGetUniformLocation(PBRShader.ID, "reflectiveness");
	uniModelMatrix = glGetUniformLocation(PBRShader.ID, "model");
	colorTextureID = glGetUniformLocation(PBRShader.ID, "colorTexture");
	nomalMapID = glGetUniformLocation(PBRShader.ID, "NormalTextureSampler");
	useNormalMapID = glGetUniformLocation(PBRShader.ID, "useNormalMap");
	dataTextureID = glGetUniformLocation(PBRShader.ID, "dataTexture");
	flameTextureID = glGetUniformLocation(PBRShader.ID, "uDiffuseSampler");
	TimeValueID = glGetUniformLocation(PBRShader.ID, "timeValue");
	texScaleID = glGetUniformLocation(PBRShader.ID, "textureScaleing");
	xxxID = glGetUniformLocation(PBRShader.ID, "xxx");
	useDissolveID = glGetUniformLocation(PBRShader.ID, "useDissolve");
	useFogID = glGetUniformLocation(PBRShader.ID, "useFog");
	useFlameID = glGetUniformLocation(PBRShader.ID, "UseFlame");
	timeID = glGetUniformLocation(PBRShader.ID, "time");
	resolutionID = glGetUniformLocation(PBRShader.ID, "resolution");
	
	planeID = glGetUniformLocation(PBRShader.ID, "plane");

	PBRShader.bind();
	glUniformMatrix4fv(glGetUniformLocation(PBRShader.ID, "rotSkybox"), 1, GL_FALSE, &curScene.rotSkybox[0][0]);
	glUniform2fv(resolutionID, 1, glm::value_ptr(glm::vec2(targetScreenWidth, targetScreenHeight)));

	glBindVertexArray(0); //Unbind the VAO in case we want to create a new one
}
void bindHDRFrameBuffer() {//call before rendering to this FBO
	//glBindFramebuffer(GL_FRAMEBUFFER, fboHDR);
	bindFrameBuffer(fboHDR, screenWidth, screenHeight);
}
void setPBRShaderUniforms(glm::mat4 view, glm::mat4 proj, glm::mat4 lightViewMatrix, glm::mat4 lightProjectionMatrix, bool useShadowMap, 
	glm::vec4 planefunc){
	//glBindFramebuffer(GL_FRAMEBUFFER, fboHDR);
	PBRShader.bind();
	glUniformMatrix4fv(uniView, 1, GL_FALSE, glm::value_ptr(view));
	glm::mat4 invView = glm::inverse(view);
	glUniformMatrix4fv(uniInvView, 1, GL_FALSE, glm::value_ptr(invView));
	glUniformMatrix4fv(uniProj, 1, GL_FALSE, glm::value_ptr(proj));

	glUniform1i(glGetUniformLocation(PBRShader.ID, "numLights"), curScene.lights.size());

	glUniform3fv(glGetUniformLocation(PBRShader.ID, "inLightDir"), curScene.lights.size(), glm::value_ptr(lightDirections[0]));
	glUniform3fv(glGetUniformLocation(PBRShader.ID, "inLightCol"), curScene.lights.size(), glm::value_ptr(lightColors[0]));

	glUniform1f(biasID, curScene.shadowLight.shadowBias);
	glUniform1i(pcfID, curScene.shadowLight.pcfWidth);

	glUniform3fv(glGetUniformLocation(PBRShader.ID, "ambientLight"), 1, glm::value_ptr(curScene.ambientLight));
	
	glUniformMatrix4fv(glGetUniformLocation(PBRShader.ID, "shadowView"), 1, GL_FALSE, &lightViewMatrix[0][0]);
	glUniformMatrix4fv(glGetUniformLocation(PBRShader.ID, "shadowProj"), 1, GL_FALSE, &lightProjectionMatrix[0][0]);

	glActiveTexture(GL_TEXTURE1); //Texture 1 in the PBR Shader is the shadow map
	glBindTexture(GL_TEXTURE_2D, depthMapTex); 
	glUniform1i(glGetUniformLocation(PBRShader.ID, "shadowMap"), 1);

	glUniform1i(glGetUniformLocation(PBRShader.ID, "useShadow"), useShadowMap && curScene.shadowLight.castShadow);

	glUniform4fv(planeID, 1, glm::value_ptr(planefunc));
}

// ---------------- Collider Geometry -----------

int createColliderSphere(int sphereVbo) {
	int stacks = 4;
	int slices = 4;
	const float PI = 3.14f;

	std::vector<float> positions;
	std::vector<float> verts;

	for (int i = 0; i <= stacks; ++i){
			float V = (float)i / (float)stacks; 
			float phi = V * PI;

			for (int j = 0; j <= slices; ++j){
					float U = (float)j / (float)slices;
					float theta = U * (PI * 2);

					// use spherical coordinates to calculate the positions.
					float x = cos(theta) * sin(phi);
					float y = cos(phi);
					float z = sin(theta) * sin(phi);

					positions.push_back(x);
					positions.push_back(y);
					positions.push_back(z);
			}
	}

	// Calc The Index Positions
	for (int i = 0; i < slices * stacks + slices; ++i){
		int s = i;
		for (int j = 0; j < 3; j++) verts.push_back(positions[3*s+j]);
		s = i + slices + 1;
		for (int j = 0; j < 3; j++) verts.push_back(positions[3*s+j]);
		s = i + slices;
		for (int j = 0; j < 3; j++) verts.push_back(positions[3*s+j]);

		s = i + slices + 1;
		for (int j = 0; j < 3; j++) verts.push_back(positions[3*s+j]);
		s = i;
		for (int j = 0; j < 3; j++) verts.push_back(positions[3*s+j]);
		s = i + 1;
		for (int j = 0; j < 3; j++) verts.push_back(positions[3*s+j]);
	}

	// upload geometry to GPU.
	glBindBuffer(GL_ARRAY_BUFFER, sphereVbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*verts.size(), verts.data(), GL_STATIC_DRAW);

	LOG_F(INFO,"Created Colider Circle with %d verts", (int)verts.size());
	return (int)verts.size();
}


void initColliderGeometry(){
	//PBRShader.bind();  //It's still bound from our call to initPBRShading()
	glGenVertexArrays(1, &colliderVAO); //Create a VAO
	glBindVertexArray(colliderVAO); //Bind the above created VAO to the current context

	GLuint colliderVBO;
    glGenBuffers(1, &colliderVBO);  //Create 1 buffer called vbo
    glBindBuffer(GL_ARRAY_BUFFER, colliderVBO); //(Only one buffer can be bound at a time) 

	//Tell OpenGL how to set fragment shader input 
	//posAttrib = glGetAttribLocation(PBRShader.ID, "position");
	glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), 0);
	glEnableVertexAttribArray(posAttrib);

	//glBufferData(GL_ARRAY_BUFFER, sizeof(cube), cube, GL_STATIC_DRAW);

	sphereVerts = createColliderSphere(colliderVBO);

    glBindVertexArray(0); //Unbind the VAO once we have set all the attributes
}


// --------  Draw Scene Geometry ----
void updatePRBShaderSkybox(){
	glActiveTexture(GL_TEXTURE5); //TODO: List what the first 5 textures are used for
	glUniform1i(glGetUniformLocation(PBRShader.ID, "skybox"),5);
	
	glUniform1i(glGetUniformLocation(PBRShader.ID, "useSkyColor"), curScene.singleSkyColor);
	if (curScene.singleSkyColor){
		glUniform3fv(glGetUniformLocation(PBRShader.ID, "skyColor"), 1, glm::value_ptr(curScene.skyColor));
	} else{
		glBindTexture(GL_TEXTURE_CUBE_MAP, cubemapTexture);
	}
}

void drawSceneGeometry(vector<Model*> toDraw, glm::mat4 viewMat){
	glBindVertexArray(modelsVAO);

	glm::mat4 I;
	totalTriangles = 0;
	for (size_t i = 0; i < toDraw.size(); i++){
		//printf("%s - %d\n",toDraw[i]->name.c_str(),i);
		drawGeometry(*toDraw[i], -1, viewMat, I);
	}
}

using glm::vec3;
using glm::vec4;


void drawSceneGeometry(std::vector<Model*> toDraw, glm::mat4 viewMat, float FOVy, float aspect, float near, float far)
{
	
	glBindVertexArray(modelsVAO);

	float g = tan(FOVy * 0.5); //focal-plane distance (ie, focal length)

	vec4 tln, trn, brn, bln, tlf, trf, brf, blf;

	//compute near plane verts:
	float y = near*g, x = y * aspect;
	trn = vec4(x,y,-near,1);
	brn = vec4(x,-y,-near,1);
	bln = vec4(-x,-y,-near,1);
	tln = vec4(-x,y,-near,1);

	//compute far plane verts:
	y = far*g, x = y * aspect;
	trf = vec4(x,y,-far,1);
	brf = vec4(x,-y,-far,1);
	blf = vec4(-x,-y,-far,1);
	tlf = vec4(-x,y,-far,1);

	vec3 nearNormal = glm::normalize(glm::cross(vec3(trn-brn),vec3(trn-tln))); //nearplane_normal = nearplane_up cross nearplane_right //TODO: This is always 0,0,-1
	vec4 nearPlane = vec4(nearNormal,-glm::dot(vec3(brn),nearNormal));
	vec3 farNormal = glm::normalize(glm::cross(vec3(tlf-trf),vec3(blf-tlf))); //farplane_normals = farplane_right cross farplane_down //TODO: This is always 0,0,1
	vec4 farPlane = vec4(farNormal,-glm::dot(vec3(brf),farNormal));

	vec3 leftNormal = glm::normalize(glm::cross(vec3(tlf-tln),vec3(tln-bln)));
	vec4 leftPlane = vec4(leftNormal,-glm::dot(vec3(bln),leftNormal));
	vec3 rightNormal = glm::normalize(glm::cross(vec3(trf-tln),vec3(brn-trn)));
	vec4 rightPlane = vec4(rightNormal,-glm::dot(vec3(brn),rightNormal));

	vec3 botNormal = glm::normalize(glm::cross(vec3(brn-bln),vec3(blf-bln)));
	vec4 botPlane = vec4(botNormal,-glm::dot(vec3(brn),botNormal));
	vec3 topNormal = glm::normalize(glm::cross(vec3(tlf-tln),vec3(trn-tln)));
	vec4 topPlane = vec4(topNormal,-glm::dot(vec3(trn),topNormal));

	glm::mat4 I;
	totalTriangles = 0;
	for (size_t i = 0; i < toDraw.size(); i++){
		//printf("%s - %d\n",toDraw[i]->name.c_str(),i);
		vec3 scaleFactor = vec3(models[toDraw[i]->ID].transform*glm::vec4(1,1,1,0));
		float radiusScale = fmaxf(scaleFactor.x,fmaxf(scaleFactor.y,scaleFactor.z)); //TODO: This won't work with relections (ie negative scales) 
		float radius = radiusScale*toDraw[i]->boundingRadius;
		vec4 objPos = models[toDraw[i]->ID].transform*glm::vec4(0,0,0,1);
		vec4 viewPos = viewMat*objPos;
		float dist;
		dist = glm::dot(farPlane,viewPos); if (dist < -radius) continue;
		dist = glm::dot(leftPlane,viewPos); if (dist < -radius) continue;
		dist = glm::dot(rightPlane,viewPos); if (dist < -radius) continue;
		dist = glm::dot(botPlane,viewPos); if (dist < -radius) continue;
		dist = glm::dot(topPlane,viewPos); if (dist < -radius) continue;
		//dist = glm::dot(nearPlane,viewPos); if (dist < -radius) continue; //End with nearplane for LOD purposes!

		drawGeometry(*toDraw[i], -1, viewMat, I, dist+near);
	}
}

//-------------  Final Composite --------------

Shader compositeShader;

unsigned int quadVAO;


void initFinalCompositeShader(){
	compositeShader = Shader("shaders/quad-vert.glsl", "shaders/quad-frag.glsl");
	compositeShader.init();
}

void drawCompositeImage(bool useBloom){
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glBindVertexArray(quadVAO);
	glClear(GL_DEPTH_BUFFER_BIT);

	float bloomLevel = 0;
	compositeShader.bind();

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, brightText); 
	glUniform1i(glGetUniformLocation(compositeShader.ID, "texBright"), 0);

	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, baseTex);  //baseTex  depthMapTex
	glUniform1i(glGetUniformLocation(compositeShader.ID, "texDim"), 1);

	if (useBloom){  
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, pingpongColorbuffers[!horizontal]); //pass in blured texture
		bloomLevel = 1;
	}

	glUniform1f(glGetUniformLocation(compositeShader.ID, "bloomAmount"), bloomLevel);

	glDrawArrays(GL_TRIANGLES, 0, 6);  //Draw Quad for final render
	glUseProgram(0);
}

// --------- Fullscreen quad
void createFullscreenQuad(){
	float quad[24] = {1,1,1,1, -1,1,0,1, -1,-1,0,0,  1,-1,1,0, 1,1,1,1, -1,-1,0,0,};

  //Build a Vertex Array Object for the full screen Quad. This stores the VBO to shader attribute mappings
	glGenVertexArrays(1, &quadVAO); //Create a VAO
	glBindVertexArray(quadVAO); //Bind the above created VAO to the current context

	GLuint quadVBO;
    glGenBuffers(1, &quadVBO);  //Create 1 buffer called vbo
    glBindBuffer(GL_ARRAY_BUFFER, quadVBO); //(Only one buffer can be bound at a time) 

	glBufferData(GL_ARRAY_BUFFER, sizeof(quad), quad, GL_STATIC_DRAW);
  
    GLint quadPosAttrib = glGetAttribLocation(compositeShader.ID, "position");
    glVertexAttribPointer(quadPosAttrib, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);
    //(above params: Attribute, vals/attrib., type, normalized?, stride, offset)
    glEnableVertexAttribArray(quadPosAttrib);

	GLint quadTexAttrib = glGetAttribLocation(compositeShader.ID, "texcoord");
	glVertexAttribPointer(quadTexAttrib, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (void*)(2*sizeof(float)));
	glEnableVertexAttribArray(quadTexAttrib); 

    glBindVertexArray(0); //Unbind the VAO once we have set all the attributes
}





/* water shader*/
Shader WaterShader;
GLuint waterVAO;
GLint waterModel, waterView, waterProj;
GLuint  reflectionFrameBuffer;
GLuint  reflectionTexture;
GLuint  reflectionDepthBuffer;

GLuint  refractionFrameBuffer;
GLuint  refractionTexture;
GLuint  refractionDepthTexture;

GLint dudvMapID , depthMapID, moveFactorID, cameraPosID, lightPosID, lightColourID, normalMapID, nearPlaneID, farPlaneID;

const float WAVESPEED = 0.0001f;
static float moveFactor = 0.0f;
void initWaterShading()
{
	WaterShader = Shader("shaders/water-vert.glsl", "shaders/water-frag.glsl");
	WaterShader.init();

	// Use a Vertex Array Object
	glGenVertexArrays(1, &waterVAO);
	glBindVertexArray(waterVAO);

	// Create a Vector Buffer Object that will store the vertices on video memory
	GLuint waterVBO;
	glGenBuffers(1, &waterVBO);

	// Allocate space and upload the data from CPU to GPU
	glBindBuffer(GL_ARRAY_BUFFER, waterVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(waterquad), waterquad, GL_STATIC_DRAW);

	// Get the location of the attributes that enters in the vertex shader
	GLint posAttrib = glGetAttribLocation(WaterShader.ID, "position");
	// Specify how the data for position can be accessed
	glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), 0);//
    // Enable the attribute
	glEnableVertexAttribArray(posAttrib);


	waterModel = glGetUniformLocation(WaterShader.ID, "modelMatrix");
	waterView = glGetUniformLocation(WaterShader.ID, "viewMatrix");
	waterProj = glGetUniformLocation(WaterShader.ID, "projectionMatrix");

	reflectionTextureID = glGetUniformLocation(WaterShader.ID, "reflectionTexture");
	refractionTextureID = glGetUniformLocation(WaterShader.ID, "refractionTexture");
	dudvMapID = glGetUniformLocation(WaterShader.ID, "dudvMap");
	normalMapID = glGetUniformLocation(WaterShader.ID, "normalMap");
	depthMapID = glGetUniformLocation(WaterShader.ID, "depthMap");
	moveFactorID = glGetUniformLocation(WaterShader.ID, "moveFactor");
	cameraPosID = glGetUniformLocation(WaterShader.ID, "cameraPos");
	lightPosID = glGetUniformLocation(WaterShader.ID, "lightPos");
	lightColourID = glGetUniformLocation(WaterShader.ID, "lightColour");
	nearPlaneID = glGetUniformLocation(WaterShader.ID, "nearPlane");
	farPlaneID = glGetUniformLocation(WaterShader.ID, "farPlane");

	

	glBindVertexArray(0); //Unbind the VAO once we have set all the attributes

	
}

void displayWater(glm::mat4 view, glm::mat4 proj, glm::vec3 camePos, glm::vec3 lightPos, glm::vec3 lightColour, float waterheight) {
	
	WaterShader.bind();
	PrepareWater();
	glBindVertexArray(waterVAO);
	glm::mat4 model = glm::mat4();
	model = glm::scale(model, glm::vec3(35, 0.5, 35));
	model = glm::translate(model, glm::vec3(0, waterheight, 0));
	//model = glm::inverse(view)*model;
	glUniformMatrix4fv(waterModel, 1, GL_FALSE, glm::value_ptr(model));
	glUniformMatrix4fv(waterProj, 1, GL_FALSE, glm::value_ptr(proj));
	glUniformMatrix4fv(waterView, 1, GL_FALSE, glm::value_ptr(view));
	glUniform3fv(cameraPosID, 1, glm::value_ptr(camePos));
	glUniform3fv(lightPosID, 1, glm::value_ptr(lightPos));
	glUniform3fv(lightColourID, 1, glm::value_ptr(lightColour));


	glDrawArrays(GL_TRIANGLES, 0, 6);//GL_TRIANGLE_STRIP
	glDisable(GL_BLEND);
	glUseProgram(0);
}
void SetRelectionView(glm::vec3& Dir, glm::vec3& Up, glm::vec3& Pos, glm::vec3& lookatPoint, float waterheight)
{
	//reverse pitch of camera
	const glm::vec3 camR = glm::cross(Dir,Up);
	float theta = asin(Dir.y / glm::length(Dir));
	glm::mat4 trans;
	Up.y>0? trans = glm::rotate(trans, -2.f*theta, camR) : trans = glm::rotate(trans, 2.f*theta, camR);
	glm::vec4 Dir4 = trans * glm::vec4(Dir, 1);
	Dir.x = Dir4.x;
	Dir.y = Dir4.y;
	Dir.z = Dir4.z;
	glm::vec4 Up4 = trans * glm::vec4(Up, 1);
	Up.x = Up4.x;
	Up.y = Up4.y;
	Up.z = Up4.z;
	float distance = 2 * (Pos.y - waterheight);
	Pos.y -= distance;
	lookatPoint = Pos + Dir;
}

void PrepareWater()
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glActiveTexture(GL_TEXTURE0);  //Set texture 0 as active texture
	glBindTexture(GL_TEXTURE_2D, reflectionTexture);//baseTex
	glUniform1i(reflectionTextureID, 0);

	glActiveTexture(GL_TEXTURE1);  
	glBindTexture(GL_TEXTURE_2D, refractionTexture);
	glUniform1i(refractionTextureID, 1);

	glActiveTexture(GL_TEXTURE2);  
	glBindTexture(GL_TEXTURE_2D, dudvTexture);
	glUniform1i(dudvMapID, 2);

	glActiveTexture(GL_TEXTURE3);  
	glBindTexture(GL_TEXTURE_2D, normalMapTexture);
	glUniform1i(normalMapID, 3);

	glActiveTexture(GL_TEXTURE4);
	glBindTexture(GL_TEXTURE_2D, refractionDepthTexture);
	glUniform1i(depthMapID, 4);

	moveFactor = fmod((moveFactor + WAVESPEED * SDL_GetTicks() / 1000.0),1.0);
	glUniform1f(moveFactorID, moveFactor);

	glUniform1f(nearPlaneID, cameraNear);
	glUniform1f(farPlaneID, cameraFar);

}
GLuint createFrameBuffer()
{
	GLuint frameBuffer;
	glGenFramebuffers(1, &frameBuffer);// generate one framebuffer
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	/*unsigned int attachments[1] = { GL_COLOR_ATTACHMENT0};
	glDrawBuffers(1, attachments);*/
	unsigned int attachments[1] = { GL_COLOR_ATTACHMENT0  };//, GL_COLOR_ATTACHMENT1
	glDrawBuffers(1, attachments);
	
	return frameBuffer;
}

GLuint createTextureAttachment(int width, int height)
{
	GLuint texture1;
	glGenTextures(1, &texture1);
	glBindTexture(GL_TEXTURE_2D, texture1);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); 
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture1, 0);//none mip map

	
	
	return texture1;
}
GLuint createDepthTextureAttachment(int width, int height)
{
	GLuint texure;
	glGenTextures(1, &texure);
	glBindTexture(GL_TEXTURE_2D, texure);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); 
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, texure, 0);//none mip map
	return texure;
}
GLuint createDepthBufferAttachment(int width, int height)
{
	GLuint rboDepth;
	glGenRenderbuffers(1, &rboDepth);
	glBindRenderbuffer(GL_RENDERBUFFER, rboDepth);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, width, height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepth);

	return rboDepth;
}
void bindReflectionFrameBuffer() {//call before rendering to this FBO
	bindFrameBuffer(reflectionFrameBuffer, REFLECTION_WIDTH, REFLECTION_HEIGHT);
}
void bindRefractionFrameBuffer() {//call before rendering to this FBO
	bindFrameBuffer(refractionFrameBuffer, REFRACTION_WIDTH, REFRACTION_HEIGHT);
}
void bindFrameBuffer(GLuint frameBuffer, int width, int height)
{
	glBindTexture(GL_TEXTURE_2D, 0);//To make sure the texture isn't bound
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	glViewport(0, 0, width, height);
}
void unbindCurrentFrameBuffer()
{
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glViewport(0, 0, screenWidth, screenHeight);
}
void initialiseReflectionFrameBuffer() {
	reflectionFrameBuffer = createFrameBuffer();
	reflectionTexture = createTextureAttachment(REFLECTION_WIDTH, REFLECTION_HEIGHT);
	reflectionDepthBuffer = createDepthBufferAttachment(REFLECTION_WIDTH, REFLECTION_HEIGHT);
	// finally check if framebuffer is complete
	CHECK_F(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, "Framebuffer not complete!");
	unbindCurrentFrameBuffer();
}

void initialiseRefractionFrameBuffer() {
	refractionFrameBuffer = createFrameBuffer();
	refractionTexture = createTextureAttachment(REFRACTION_WIDTH, REFRACTION_HEIGHT);
	refractionDepthTexture = createDepthTextureAttachment(REFRACTION_WIDTH, REFRACTION_HEIGHT);
	// finally check if framebuffer is complete
	CHECK_F(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, "Framebuffer not complete!");
	unbindCurrentFrameBuffer();
}
void initWaterFrameBuffers() {//call when loading the game
	/*initialiseReflectionFrameBuffer();
	initialiseRefractionFrameBuffer();*/
	reflectionFrameBuffer = createFrameBuffer();
	glGenTextures(1, &reflectionTexture);
	glBindTexture(GL_TEXTURE_2D, reflectionTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, REFLECTION_WIDTH, REFLECTION_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	/*glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);*/
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, reflectionTexture, 0);


	// create and attach depth buffer (renderbuffer)
	glGenRenderbuffers(1, &reflectionDepthBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, reflectionDepthBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, REFLECTION_WIDTH, REFLECTION_HEIGHT);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, reflectionDepthBuffer);

	// finally check if framebuffer is complete
	CHECK_F(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, "Framebuffer not complete!");
	glBindFramebuffer(GL_FRAMEBUFFER, 0);

	refractionFrameBuffer = createFrameBuffer();
	glGenTextures(1, &refractionTexture);
	glBindTexture(GL_TEXTURE_2D, refractionTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, REFRACTION_WIDTH, REFRACTION_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	/*glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);*/
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, refractionTexture, 0);
	
	glGenTextures(1, &refractionDepthTexture);
	glBindTexture(GL_TEXTURE_2D, refractionDepthTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32, REFRACTION_WIDTH, REFRACTION_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	/*glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);*/
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, refractionDepthTexture, 0);//none mip map

	// finally check if framebuffer is complete
	CHECK_F(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, "Framebuffer not complete!");
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}
 /*********************************************LensFlare*******************************************************/
#define FLARENUM 11 
const float flarequad[] = { -0.5f, -0.5f, -0.5f, 0.5f, 0.5f, -0.5f, 0.5f, 0.5f };
Shader LensFlareShader;
GLuint FlareVAO;
GLuint transformID, flareTextureID, brightnessID;
vector<FlareTexture*> flareTextures;
void initLensFlareShading()
{
	LensFlareShader = Shader("shaders/flareVertex.glsl", "shaders/flareFragment.glsl");
	LensFlareShader.init();

	// Use a Vertex Array Object
	glGenVertexArrays(1, &FlareVAO);
	glBindVertexArray(FlareVAO);

	// Create a Vector Buffer Object that will store the vertices on video memory
	GLuint flareVBO;
	glGenBuffers(1, &flareVBO);

	// Allocate space and upload the data from CPU to GPU
	glBindBuffer(GL_ARRAY_BUFFER, flareVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(flarequad), flarequad, GL_STATIC_DRAW);

	// Get the location of the attributes that enters in the vertex shader
	GLint posAttrib = glGetAttribLocation(LensFlareShader.ID, "in_position");
	// Specify how the data for position can be accessed
	glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), 0);
	// Enable the attribute
	glEnableVertexAttribArray(posAttrib);

	transformID = glGetUniformLocation(LensFlareShader.ID, "transform");
	flareTextureID = glGetUniformLocation(LensFlareShader.ID, "flareTexture");
	brightnessID = glGetUniformLocation(LensFlareShader.ID, "brightness");

	glBindVertexArray(0);

	flareTextures.push_back(new FlareTexture(flaretex[5], 0.1f));
	flareTextures.push_back(new FlareTexture(flaretex[3], 0.23f));
	flareTextures.push_back(new FlareTexture(flaretex[1], 0.1f));
	flareTextures.push_back(new FlareTexture(flaretex[6], 0.05f));
	flareTextures.push_back(new FlareTexture(flaretex[2], 0.06f));
	flareTextures.push_back(new FlareTexture(flaretex[4], 0.07f));
	flareTextures.push_back(new FlareTexture(flaretex[6], 0.2f));
	flareTextures.push_back(new FlareTexture(flaretex[2], 0.07f));
	flareTextures.push_back(new FlareTexture(flaretex[4], 0.3f));
	flareTextures.push_back(new FlareTexture(flaretex[3], 0.4f));
	flareTextures.push_back(new FlareTexture(flaretex[7], 0.6f));
	

}
void renderFlare(FlareTexture* flare)
{
	glActiveTexture(GL_TEXTURE0);  //Set texture 0 as active texture
	glBindTexture(GL_TEXTURE_2D, flare->texture);//baseTex
	glUniform1i(flareTextureID, 0);
	float xScale = flare->scale;
	float yScale = xScale * (float)(screenWidth) / (float)(screenHeight);
	glm::vec4 transfrom = glm::vec4(flare->screenPos.x, flare->screenPos.y, xScale, yScale);
	//std::cout << flare->screenPos.x << " " << flare->screenPos.y << " " << xScale << " " << yScale << endl;
	glUniform4fv(transformID, 1, glm::value_ptr(transfrom));
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
void LensFlarerender(glm::mat4 view, glm::mat4 proj, glm::vec3 sunWorldPos)
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glDisable(GL_MULTISAMPLE);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE); // default is disable
	glm::vec2 CENTER_SCREEN = glm::vec2(0.5f, 0.5f);
	glm::vec2 sunCoords = convertToScreenSpace(sunWorldPos, view, proj);
	
	if (glm::all(glm::equal(sunCoords, glm::vec2(-1, -1))))
	{
		glDisable(GL_BLEND);
		glEnable(GL_DEPTH_TEST);
		glUseProgram(0);
		return;
	}
	glm::vec2 sunToCenter = CENTER_SCREEN - sunCoords;
	//std::cout << sunCoords.x << " " << sunCoords.y << endl;;
	float brightness = 1 - (glm::length(sunToCenter) / 0.8f);
	//std::cout << brightness << endl;
	if (brightness > 0) {
		
		calcFlarePositions(sunToCenter, sunCoords,0.3f);
		// Render
		LensFlareShader.bind();
		glBindVertexArray(FlareVAO);
		glUniform1f(brightnessID, brightness);
		for (FlareTexture* flare : flareTextures)
		{
			renderFlare(flare);
		}
	}
	glDisable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	glUseProgram(0);
}
glm::vec2 convertToScreenSpace(glm::vec3 worldPos, glm::mat4 viewMat, glm::mat4 projectionMat)
{
	glm::vec4 coords = glm::vec4(worldPos.x, worldPos.y, worldPos.z, 1.0f);
	coords = projectionMat*viewMat * coords;
	if (coords.w <= 0) {
		return glm::vec2(-1, -1);
	}
	float x = (coords.x / coords.w + 1) / 2.0f;
	float y = 1 - ((coords.y / coords.w + 1) / 2.0f);
	return glm::vec2(x, y);
	
}
void calcFlarePositions(glm::vec2 sunToCenter, glm::vec2 sunCoords, float spacing)
{
	for (int i = 0; i < flareTextures.size(); i++) {
		glm::vec2 direction = glm::vec2(sunToCenter);
		direction = i * spacing * direction;
		glm::vec2 flarePos = sunCoords + direction;
		flareTextures[i]->setScreenPos(flarePos);
	}
	return;
}



/************************fire shader***********************************************/
static const GLfloat billboard[] =
{
	 -0.5f, -0.5f, 0.0f,
	  0.5f, -0.5f, 0.0f,
	 -0.5f,  0.5f, 0.0f,
	  0.5f,  0.5f, 0.0f,
};
const int maxfirenum = 5;
int firecount = 1;
Shader flameShader;
GLuint CameraRight_worldspaceID, CameraUp_worldspaceID, VPID, uDiffuseSamplerID, flametimeID;
GLuint FlameVAO;
GLuint position_buffer;
static GLfloat* fire_position_size_data = new GLfloat[maxfirenum * 4]; //fire position
void initFireShading()
{
	flameShader = Shader("shaders/flame-vert.glsl", "shaders/flame-frag.glsl");
	flameShader.init();

	// Use a Vertex Array Object
	glGenVertexArrays(1, &FlameVAO);
	glBindVertexArray(FlameVAO);

	// The VBO containing the positions and sizes of the particles
	glGenBuffers(1, &position_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, position_buffer);
	// Initialize with empty (NULL) buffer : it will be updated later, each frame.
	glBufferData(GL_ARRAY_BUFFER, maxfirenum * 4 * sizeof(GLfloat), NULL, GL_STREAM_DRAW);

	// Create a Vector Buffer Object that will store the vertices on video memory
	GLuint flameVBO;
	glGenBuffers(1, &flameVBO);
	// Allocate space and upload the data from CPU to GPU
	glBindBuffer(GL_ARRAY_BUFFER, flameVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(billboard), billboard, GL_STATIC_DRAW);


	// Get the location of the attributes that enters in the vertex shader
	GLint posAttrib = glGetAttribLocation(flameShader.ID, "squareVertices");
	// Enable the attribute
	glEnableVertexAttribArray(posAttrib);
	// Specify how the data for position can be accessed
	glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), 0);
	

	

	CameraRight_worldspaceID = glGetUniformLocation(flameShader.ID, "CameraRight_worldspace");
	CameraUp_worldspaceID = glGetUniformLocation(flameShader.ID, "CameraUp_worldspace");
	VPID = glGetUniformLocation(flameShader.ID, "VP");
	uDiffuseSamplerID = glGetUniformLocation(flameShader.ID, "uDiffuseSampler");
	flametimeID = glGetUniformLocation(flameShader.ID, "time");



	glBindVertexArray(0);
}

void renderFlame(glm::vec3 CameraRight_worldspace, glm::vec3 CameraUp_worldspace, glm::mat4 VP)
{
	flameShader.bind();
	fire_position_size_data[0] = 0;
	fire_position_size_data[1] = 1.5;
	fire_position_size_data[2] = 0;
	fire_position_size_data[3] = 1.5;


	glBindBuffer(GL_ARRAY_BUFFER, position_buffer);
	glBufferData(GL_ARRAY_BUFFER, maxfirenum * 4 * sizeof(GLfloat), NULL, GL_STREAM_DRAW); // Buffer orphaning, a common way to improve streaming perf. See above link for details.
	glBufferSubData(GL_ARRAY_BUFFER, 0, firecount * sizeof(GLfloat) * 4, fire_position_size_data);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBindVertexArray(FlameVAO);

	glActiveTexture(GL_TEXTURE0);  //Set texture 0 as active texture
	glBindTexture(GL_TEXTURE_2D, flametex);//baseTex
	glUniform1i(uDiffuseSamplerID, 0);

	float time  = SDL_GetTicks();//fmod( , 1.0)
	glUniform1f(flametimeID, moveFactor);

	glUniform3fv(CameraRight_worldspaceID, 1, glm::value_ptr(CameraRight_worldspace));
	glUniform3fv(CameraUp_worldspaceID, 1, glm::value_ptr(CameraUp_worldspace));
	glUniformMatrix4fv(VPID, 1, GL_FALSE, glm::value_ptr(VP));
	
	
	
	

	// 2nd attribute buffer : positions of particles' centers

	GLint posAttrib = glGetAttribLocation(flameShader.ID, "xyzs");
	glBindBuffer(GL_ARRAY_BUFFER, position_buffer);
	glVertexAttribPointer(
		1, // attribute. No particular reason for 1, but must match the layout in the shader.
		4, // size : x + y + z + size => 4
		GL_FLOAT, // type
		GL_FALSE, // normalized?
		0, // stride
		(void*)0 // array buffer offset
	);
	glEnableVertexAttribArray(posAttrib);
	// These functions are specific to glDrawArrays*Instanced*.
	// The first parameter is the attribute buffer we're talking about.
	// The second parameter is the "rate at which generic vertex attributes advance when rendering multiple instances"
	glVertexAttribDivisor(0, 0); // particles vertices : always reuse the same 4 vertices -> 0
	glVertexAttribDivisor(1, 1); // positions : one per quad (its center)                 -> 1                        -> 1

	// Draw the billboards !
	glDrawArraysInstanced(GL_TRIANGLE_STRIP, 0, 4, firecount);
	//glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	glDisable(GL_BLEND);
	glDisableVertexAttribArray(posAttrib);
	glUseProgram(0);
}




/******************************Terrain*************************************/
//Model Terrain::generateTerrain(Loader loader)
//{
//	int count = VERTEX_COUNT * VERTEX_COUNT;
//	float* vertices = new float[count * 3];
//	float* normals = new float[count * 3];
//	float* textureCoords = new float[count * 2];
//	int* indices = new int[6 * (VERTEX_COUNT - 1)*(VERTEX_COUNT - 1)];
//	int vertexPointer = 0;
//	for (int i = 0; i < VERTEX_COUNT; i++) {
//		for (int j = 0; j < VERTEX_COUNT; j++) {
//			vertices[vertexPointer * 3] = (float)j / ((float)VERTEX_COUNT - 1) * SIZE;
//			vertices[vertexPointer * 3 + 1] = 0;
//			vertices[vertexPointer * 3 + 2] = (float)i / ((float)VERTEX_COUNT - 1) * SIZE;
//			normals[vertexPointer * 3] = 0;
//			normals[vertexPointer * 3 + 1] = 1;
//			normals[vertexPointer * 3 + 2] = 0;
//			textureCoords[vertexPointer * 2] = (float)j / ((float)VERTEX_COUNT - 1);
//			textureCoords[vertexPointer * 2 + 1] = (float)i / ((float)VERTEX_COUNT - 1);
//			vertexPointer++;
//		}
//	}
//	int pointer = 0;
//	for (int gz = 0; gz < VERTEX_COUNT - 1; gz++) {
//		for (int gx = 0; gx < VERTEX_COUNT - 1; gx++) {
//			int topLeft = (gz*VERTEX_COUNT) + gx;
//			int topRight = topLeft + 1;
//			int bottomLeft = ((gz + 1)*VERTEX_COUNT) + gx;
//			int bottomRight = bottomLeft + 1;
//			indices[pointer++] = topLeft;
//			indices[pointer++] = bottomLeft;
//			indices[pointer++] = topRight;
//			indices[pointer++] = topRight;
//			indices[pointer++] = bottomLeft;
//			indices[pointer++] = bottomRight;
//		}
//	}
//	return loader.loadToVAO(vertices, textureCoords, normals, indices);
//}
float Terrain::SIZE = 800;
float Terrain::VERTEX_COUNT = 128;

void cleanupBuffers() {
	glDeleteBuffers(1, &modelsVBO);
	glDeleteVertexArrays(1, &modelsVAO);
	glDeleteVertexArrays(1, &colliderVAO);
	glDeleteVertexArrays(1, &waterVAO);
	glDeleteTextures(1, &FlareVAO);
	//TODO: Clearn up the other VAOs and VBOs
	glDeleteFramebuffers(1,&reflectionFrameBuffer);
	glDeleteTextures(1,&reflectionTexture);
	glDeleteRenderbuffers(1,&reflectionDepthBuffer);
	glDeleteFramebuffers(1,&refractionFrameBuffer);
	glDeleteTextures(1,&refractionTexture);
	glDeleteTextures(1,&refractionDepthTexture);
	

}
