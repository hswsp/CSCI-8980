#ifndef RENDERING_H
#define RENDERING_H

#include "RenderingCore.h"
#include "Scene.h"
#include "Materials.h"
#include "Models.h"

extern std::vector<Model*> toDraw;
extern bool xxx; //

//Main geometry drawing functions
void initPBRShading();
void setPBRShaderUniforms(glm::mat4 view, glm::mat4 proj, glm::mat4 lightViewMatrix, glm::mat4 lightProjectionMatrix, bool useShadowMap);
void drawSceneGeometry(std::vector<Model*> toDraw);
void drawSceneGeometry(std::vector<Model*> toDraw, glm::mat4 viewMat, float FOV, float aspect, float near, float far);

//HDR render targets
void initHDRBuffers();
void initMyShading();
void displayMyObj(glm::mat4 view, glm::mat4 proj, float time);

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

#endif //RENDERING_H