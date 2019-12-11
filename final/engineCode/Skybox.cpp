#include "GPU-Includes.h"
#include "Shader.h"
#include "Scene.h"
#include <external/stb_image.h>
#include <external/loguru.hpp>

using std::vector;


Shader skyboxShader;
GLuint skyboxVAO;

vector<std::string> faces,Nightfaces;
extern bool useFog;
bool Isnight;
unsigned int cubemapTexture, cubemapTexture2;


void initSkyboxShader(){
	skyboxShader = Shader("shaders/skybox-vert.glsl", "shaders/skybox-frag.glsl");
	skyboxShader.init();
}

static const GLfloat cube[108] = {
    -1.0f,-1.0f,-1.0f, -1.0f,-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, //Triangle 1
    1.0f, 1.0f,-1.0f, -1.0f,-1.0f,-1.0f, -1.0f, 1.0f,-1.0f,  // Triangle 2
    1.0f,-1.0f, 1.0f, -1.0f,-1.0f,-1.0f, 1.0f,-1.0f,-1.0f, //..
    1.0f, 1.0f,-1.0f, 1.0f,-1.0f,-1.0f, -1.0f,-1.0f,-1.0f,
    -1.0f,-1.0f,-1.0f,-1.0f, 1.0f, 1.0f,-1.0f, 1.0f,-1.0f,
    1.0f,-1.0f, 1.0f,-1.0f,-1.0f, 1.0f,-1.0f,-1.0f,-1.0f,
    -1.0f, 1.0f, 1.0f,-1.0f,-1.0f, 1.0f,1.0f,-1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,1.0f,-1.0f,-1.0f,1.0f, 1.0f,-1.0f,
    1.0f,-1.0f,-1.0f,1.0f, 1.0f, 1.0f, 1.0f,-1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,1.0f, 1.0f,-1.0f,-1.0f, 1.0f,-1.0f,
    1.0f, 1.0f, 1.0f, -1.0f, 1.0f,-1.0f,-1.0f, 1.0f, 1.0f,
    1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f,1.0f,-1.0f, 1.0f};

unsigned int loadCubemap(std::string dir, vector<std::string> cubeFaces){
	LOG_SCOPE_FUNCTION(INFO); //Group logging info about the cubmap loading

	unsigned int cubemapTexID;
	glGenTextures(1, &cubemapTexID);
	glBindTexture(GL_TEXTURE_CUBE_MAP, cubemapTexID);

	int width, height, nrChannels;
	stbi_set_flip_vertically_on_load(false);
	for (unsigned int i = 0; i < cubeFaces.size(); i++){
		string faceImg = dir + cubeFaces[i];
		unsigned char *pixelData = stbi_load(faceImg.c_str(), &width, &height, &nrChannels, STBI_rgb);
		CHECK_NOTNULL_F(pixelData,"Cubemap texture failed to load: %s",faceImg.c_str());

		if (width%32 != 0) glPixelStorei(GL_UNPACK_ALIGNMENT, 1); //Something like this is needed to support images of unusal size (eg., not divisible by 32) //TODO: is 32 the right check?
		LOG_IF_F(WARNING, width%32 != 0, "Setting GL Unpack alignment to handle non-aligned images (ie row is not word-aligned)");

		glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 
									0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
		stbi_image_free(pixelData);
	}
	//glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

	return cubemapTexID;
} 

void loadSkyboxToGPU(){
	if (!curScene.singleSkyColor){
		cubemapTexture = loadCubemap(curScene.environmentMap,faces);
	}	
}

GLuint skyboxID, skybox2ID, blendFactorID;
void initSkyboxBuffers(){
	glGenVertexArrays(1, &skyboxVAO); //Create a VAO
	glBindVertexArray(skyboxVAO); //Bind the above created VAO to the current context

	GLuint skyboxVBO;
  glGenBuffers(1, &skyboxVBO);  //Create 1 buffer called vbo
  glBindBuffer(GL_ARRAY_BUFFER, skyboxVBO); //(Only one buffer can be bound at a time) 

	//Tell OpenGL how to set fragment shader input 
	GLuint posAttrib = glGetAttribLocation(skyboxShader.ID, "pos");
	glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), 0);
	glEnableVertexAttribArray(posAttrib);

	glBufferData(GL_ARRAY_BUFFER, sizeof(cube), cube, GL_STATIC_DRAW);
	faces = {"posx.jpg", "negx.jpg", "posy.jpg", "negy.jpg", "posz.jpg", "negz.jpg"};
	Nightfaces = { "posx.png", "negx.png", "posy.png", "negy.png", "posz.png", "negz.png" };
	if (!curScene.singleSkyColor){
		cubemapTexture = loadCubemap(curScene.environmentMap,faces);
		cubemapTexture2 = loadCubemap(string("./SkyBoxes/Night/"), Nightfaces);
	}

	skyboxShader.bind();
	glUniformMatrix4fv(glGetUniformLocation(skyboxShader.ID, "rotSkybox"), 1, GL_FALSE, &curScene.rotSkybox[0][0]);

	skyboxID = glGetUniformLocation(skyboxShader.ID, "skybox");
	skybox2ID = glGetUniformLocation(skyboxShader.ID, "skybox2");
	blendFactorID = glGetUniformLocation(skyboxShader.ID, "blendFactor");
  glBindVertexArray(0); //Unbind the VAO once we have set all the attributes
}

const float ROTATION_SPEED = 1.0f;
static float  rotation = 0.0f;
void drawSkybox(glm::mat4 view, glm::mat4 proj){
	//Draw Skybox (but only where depth is infinity/max value)
	rotation = ROTATION_SPEED * SDL_GetTicks() / 1000.0;
	glDepthFunc(GL_LEQUAL); //Draw anything that is at the same value as the depth buffer
	skyboxShader.bind();
	glBindVertexArray(skyboxVAO);

	glm::mat4 viewNoTrans = glm::mat4(glm::mat3(view)); //strip out translate of skybox (rotate only)
	viewNoTrans = glm::rotate(viewNoTrans, glm::radians(rotation), glm::vec3(0, 1, 0));

	glUniformMatrix4fv(glGetUniformLocation(skyboxShader.ID, "view"), 1, GL_FALSE, glm::value_ptr(viewNoTrans));
	glUniformMatrix4fv(glGetUniformLocation(skyboxShader.ID, "proj"), 1, GL_FALSE, glm::value_ptr(proj));

	glUniform1i(glGetUniformLocation(skyboxShader.ID, "constColor"), curScene.singleSkyColor);
	if (curScene.singleSkyColor){
		glUniform3fv(glGetUniformLocation(skyboxShader.ID, "skyColor"), 1, glm::value_ptr(curScene.skyColor));
	}
	else{

		float skyboxTime = SDL_GetTicks();
		skyboxTime = fmod(skyboxTime,24000.0f);
		GLuint texture1, texture2;
		float blendFactor;
		if (skyboxTime >= 0 && skyboxTime < 5000) {
			texture1 = cubemapTexture2;
			texture2 = cubemapTexture2;
			blendFactor = (skyboxTime - 0) / (5000 - 0);
			Isnight = true;
		}
		else if (skyboxTime >= 5000 && skyboxTime < 11000) {
			texture1 = cubemapTexture2;
			texture2 = cubemapTexture;
			blendFactor = (skyboxTime - 5000) / (11000 - 5000);
			Isnight = true;
		}
		else if (skyboxTime >= 11000 && skyboxTime < 21000) {
			texture1 = cubemapTexture;
			texture2 = cubemapTexture;
			blendFactor = (skyboxTime - 11000) / (21000 - 8000);
			Isnight = false;
		}
		else {
			texture1 = cubemapTexture;
			texture2 = cubemapTexture2;
			blendFactor = (skyboxTime - 21000) / (24000 - 21000);
			Isnight = true;
		}

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_CUBE_MAP, texture1);
		glUniform1i(skyboxID,0);
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_CUBE_MAP, texture2);
		glUniform1i(skybox2ID, 1);

		glUniform1f(blendFactorID, blendFactor);
		
	}
	glUniform1i(glGetUniformLocation(skyboxShader.ID, "useFog"), useFog); 

	glDrawArrays(GL_TRIANGLES, 0, 36);
	glDepthFunc(GL_LESS); // set depth function back to default
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glUseProgram(0);
}
