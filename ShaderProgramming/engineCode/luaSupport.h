#ifndef LUASUPPORT_H
#define LUASUPPORT_H

//LUA includes
extern "C" {
    #include "Lua/src/lua.h"
    #include "Lua/src/lauxlib.h"
    #include "Lua/src/lualib.h"
}

void luaSetup(lua_State * L);

//TODO: Maybe move related lua functions to the .h/.cpp files that provide them
//      e.g. move laodAudio, playSound, and playSoundEffect lua calls to Audiomanager

#include "Sound.h"
int setDissolve(lua_State * L);
int setFog(lua_State * L);
extern AudioManager audioManager;
int starttime(lua_State * L);
int pushcontrol(lua_State * L);
int getTargetFPS(lua_State * L);
int loadAudio(lua_State * L); //load audio file into sound manager
int playSong(lua_State * L); //plays background music
int playSoundEffect(lua_State * L); //plays short sound effect
int pauseSound(lua_State * L); //pause all sounds
int unpauseSound(lua_State * L); //pause all sounds
int getTargetFPS(lua_State * L);
int getScoresFromLua(lua_State * L); // Get the score of thethe game

int addModel(lua_State * L); //Adds model to be drawn
int findModel(lua_State * L); //Find model ID based on name
int getChild(lua_State * L); //Find a child model (pre-fab) with a given name
int selectChild(lua_State * L); //Draw only 1 of the n children

int deleteModel(lua_State * L); //Stop drawing model (will auto continue if you draw a model of the same type)
int hideModel(lua_State * L); //Stop drawing model
int unhideModel(lua_State * L); //Continue drawing model

int scaleModel(lua_State * L);
int setModelMaterial(lua_State * L);
int setModelColor(lua_State * L);

int placeModel(lua_State * L);
int placeModelAtAngle(lua_State * L);
int resetModelTransform(lua_State * L);
int translateModel(lua_State * L);
int rotateModel(lua_State * L);
int resetTransformation(lua_State * L);
int setModelTransform(lua_State * L);
int getModelPos(lua_State * L);
int getModelScale(lua_State * L);

int SetSkyBox(lua_State * L);
int SetGameInfo(lua_State * L);

#include "GPU-Includes.h"
glm::vec3 getCameraPosFromLua(lua_State * L);
glm::vec3 getCameraDirFromLua(lua_State * L);
glm::vec3 getCameraUpFromLua(lua_State * L);


//Collision System
int addCollider(lua_State * L);
int getCollisionsWithLayer(lua_State * L);
int intersectMouseWithLayer(lua_State * L);
int getRayCollisionWithLayer(lua_State * L);

#endif //LUASUPPORT_H