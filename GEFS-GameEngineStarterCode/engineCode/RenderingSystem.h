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
void initfrustumShading();
void Generate_frustum_vertices_position(float nearPlane, float farPlane);
void displayFrustum(glm::mat4 view, glm::mat4 proj, glm::mat4 mainview);
void setPBRShaderUniforms(glm::mat4 view, glm::mat4 proj, glm::mat4 lightViewMatrix, glm::mat4 lightProjectionMatrix, bool useShadowMap);
void drawSceneGeometry(std::vector<Model*> toDraw);
void drawSceneGeometry(std::vector<Model*> toDraw, glm::vec3 forward, glm::vec3 camPos, float nearplane, float farPlane);

//HDR render targets
void initHDRBuffers();

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