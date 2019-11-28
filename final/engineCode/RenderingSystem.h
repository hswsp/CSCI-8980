#ifndef RENDERING_H
#define RENDERING_H
#include "WindowManager.h"
#include "RenderingCore.h"
#include "Scene.h"
#include "Materials.h"
#include "Models.h"

extern std::vector<Model*> toDraw;
extern bool xxx; //

//Main geometry drawing functions
void initPBRShading();
void setPBRShaderUniforms(glm::mat4 view, glm::mat4 proj, glm::mat4 lightViewMatrix, glm::mat4 lightProjectionMatrix, bool useShadowMap,
	glm::vec4 planefunc);
void drawSceneGeometry(std::vector<Model*> toDraw);
void drawSceneGeometry(std::vector<Model*> toDraw, glm::mat4 viewMat, float FOV, float aspect, float near, float far);

//HDR render targets
void initHDRBuffers();
void bindHDRFrameBuffer();
void initWaterShading();

//Collider spheres drawing function
void initColliderGeometry();
void drawColliderGeometry();
int createSphere(int sphereVbo);

//Final compositing functions
void initFinalCompositeShader();
void drawCompositeImage(bool useBloom);

//Cleanup
void cleanupBuffers();

//Global values we write out:
extern int totalTriangles;
extern GLuint modelsVBO;

// refraction and reflection buffer
static int REFLECTION_WIDTH = 1280;
static int REFLECTION_HEIGHT = 720;
static int REFRACTION_WIDTH = 960; 
static int REFRACTION_HEIGHT = 600; 
void displayWater(glm::mat4 view, glm::mat4 proj, float waterheight = 0);



GLuint createFrameBuffer();
GLuint createTextureAttachment(int width, int height);
GLuint createDepthTextureAttachment(int width, int height);
GLuint createDepthBufferAttachment(int width, int height);
void bindFrameBuffer(GLuint frameBuffer, int width, int height);
void unbindCurrentFrameBuffer();
void bindReflectionFrameBuffer();
void bindRefractionFrameBuffer();
void initialiseReflectionFrameBuffer();
void initialiseRefractionFrameBuffer();
void initWaterFrameBuffers();
void PrepareWater();
void SetRelectionView(Camera& camera, float waterheight = 0);
void SetRelectionView(glm::vec3& Dir, glm::vec3& Up, glm::vec3& Pos, glm::vec3& lookatPoint, float waterheight = 0);
#endif //RENDERING_H