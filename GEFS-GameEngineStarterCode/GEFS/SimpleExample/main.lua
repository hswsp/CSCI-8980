--Simple Example
print("Starting Lua for Simple Example")
require "CommonLibs/vec3"

CameraPosX = -3.0
CameraPosY = 1.0
CameraPosZ = 0.0 

CameraDirX = 1.0
CameraDirY = -0.0
CameraDirZ = -0.0

CameraUpX = 0.0
CameraUpY = 1.0
CameraUpZ = 0.0

animatedModels = {}
velModel = {}
rotYVelModel = {}

targetFrameRate = getTargetFPS();
CameraP = vec3(CameraPosX,CameraPosY,CameraPosZ);
CameraDir = vec3(CameraDirX,CameraDirY,CameraDirZ);
frameVel = 0.001
modelsize = 1
-- function rotateY(v,theta)
--   local out
--   rotquat = quat(quat(math.cos(theta),0.-math.sin(theta),0),quat(0,1,0,0),
--             quat(math.sin(theta),0,math.cos(theta),0),quat(0,0,0,1))
--   vec3.rotate(v,rotquat,out)
--   return out
-- end

function frameUpdate(dt)
  for modelID,v in pairs(animatedModels) do
    --print("ID",modelID)
    local vel = velModel[modelID]
    if vel then 
      translateModel(modelID,dt*vel[1],dt*vel[2],dt*vel[3])
    end

    local rotYvel = rotYVelModel[modelID]
    if rotYvel then 
      rotateModel(modelID,rotYvel*dt, 0, 1, 0)
    end

  end
end

function keyHandler(keys)
  if keys.left then
    --translateModel(dinoID,0,0,-0.1)
    local X = CameraDirX
    local Z = CameraDirZ
    local theta = targetFrameRate * frameVel
    CameraDirX = math.cos(theta)*X + math.sin(theta)*Z
    CameraDirZ = math.cos(theta)*Z - math.sin(theta)*X
  end
  if keys.right then
    --translateModel(dinoID,0,0,0.1)
    local X = CameraDirX
    local Z = CameraDirZ
    local theta = targetFrameRate *frameVel
    CameraDirX = math.cos(theta)*X - math.sin(theta)*Z
    CameraDirZ = math.cos(theta)*Z + math.sin(theta)*X
  end
  if keys.up then
    --translateModel(dinoID,0.1,0,0)
    CameraPosX = CameraPosX + targetFrameRate *frameVel * CameraDirX;
    CameraPosY = CameraPosY + targetFrameRate *frameVel * CameraDirY;
    CameraPosZ = CameraPosZ + targetFrameRate *frameVel * CameraDirZ;

  end
  if keys.down then
    --translateModel(dinoID,-0.1,0,0)
    CameraPosX = CameraPosX - targetFrameRate *frameVel * CameraDirX;
    CameraPosY = CameraPosY - targetFrameRate *frameVel * CameraDirY;
    CameraPosZ = CameraPosZ - targetFrameRate *frameVel * CameraDirZ;

  end
  if keys.w then
    local X = CameraDirX
    local Y = CameraDirY
    local theta = targetFrameRate *frameVel
    CameraDirX = math.cos(theta)*X - math.sin(theta)*Y
    CameraDirY = math.cos(theta)*Y + math.sin(theta)*X

  end
  if keys.s then
    local X = CameraDirX
    local Y = CameraDirY
    local theta = targetFrameRate *frameVel
    CameraDirX = math.cos(theta)*X + math.sin(theta)*Y
    CameraDirY = math.cos(theta)*Y - math.sin(theta)*X

  end
end

for i=-10,10 do
  for j = -10,10 do
    teapotID = addModel("Teapot",i*modelsize,0,j*modelsize)
    setModelMaterial(teapotID,"Shiny Red Plastic")
    --setModelMaterial(teapotID,"Steel")
    animatedModels[teapotID] = true
    rotYVelModel[teapotID] = 1
  end
end

floorID = addModel("FloorPart",0,0,0)
placeModel(floorID,0,-.02,0)
scaleModel(floorID,300,1,300)
setModelMaterial(floorID,"Gold")

dinoID = addModel("Dino",0,0,-.15)

RimID = addModel("Bigmax",0,0,0)
placeModel(RimID,-1,0.5,1)
scaleModel(RimID,0.01,0.01,0.01)