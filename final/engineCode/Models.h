#ifndef MODELS_H
#define MODELS_H

#include "Materials.h"
#include "CollisionSystem.h"
#include "GPU-Includes.h"
#include <vector>
#include <string>

struct Model{
  std::string name = "**UNNAMED Model**";
	int ID = -1;
	glm::mat4 transform;
	glm::mat4 modelOffset; //Just for placing geometry, not passed down the scene graph
	float* modelData = nullptr;
	int startVertex;
	float* TangentData = nullptr;
	int normalMapID = -1;

	int startTangentVertex;
	int numVerts = 0;
	int numChildren = 0;
	int materialID = -1;
	int selector = -1; //-1 = all children, >= 0 only that child
	float boundingRadius = 0;
	Collider* collider = nullptr;
	glm::vec2 textureWrap = glm::vec2(1,1);
	glm::vec3 modelColor = glm::vec3(1,1,1); //TODO: Perhaps we can replace this simple approach with a more general material blending system?
	std::vector<Model*> childModel;
	Model* lodChild = nullptr; //TODO: We assume only one LOD child, do we need to suport more?
	float lodDist = 5;

	bool IsDissolve = false;
	bool finishDisslve = false;
	float tValue = 1;
	bool decrease = true;
};

void resetModels();
void loadModel(string fileName);

void loadAllModelsTo1VBO(GLuint vbo);
int addModel(string modelName);
void addChild(string childName, int curModelID);
void setNormalChild(Model* model, int numnormalMaps);
//Global Model List
extern Model models[10000];
extern int numModels;

#endif //MODELS_H