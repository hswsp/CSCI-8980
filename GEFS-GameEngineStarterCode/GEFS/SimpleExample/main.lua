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

CameraRtX = 0
CameraRtY = 0
CameraRtZ = 0
-- debug Camera
DebugCameraPosX = -3.0
DebugCameraPosY = 1.0
DebugCameraPosZ = 0.0 

DebugCameraDirX = 1.0
DebugCameraDirY = -0.0
DebugCameraDirZ = -0.0

DebugCameraUpX = 0.0
DebugCameraUpY = 1.0
DebugCameraUpZ = 0.0

DebugCameraRtX = 0
DebugCameraRtY = 0
DebugCameraRtZ = 0

animatedModels = {}
velModel = {}
rotYVelModel = {}

targetFrameRate = getTargetFPS();
CameraP = vec3(CameraPosX,CameraPosY,CameraPosZ);
CameraDir = vec3(CameraDirX,CameraDirY,CameraDirZ);
frameVel = 0.001
modelsize = 1

DebugCam = false
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
      translateModel(modelID, -vel[1]*math.sin(dt*vel[1]),dt*vel[2],vel[3]*math.cos(dt*vel[3]))
    end

    local rotYvel = rotYVelModel[modelID]
    if rotYvel then 
      rotateModel(modelID,rotYvel*dt, 0, 1, 0)
    end

  end
end
function computeCameraRight()
  CameraRtX = CameraDirY*CameraUpZ - CameraDirZ*CameraUpY
  CameraRtY = CameraDirZ*CameraUpX - CameraDirX*CameraUpZ
  CameraRtZ = CameraDirX*CameraUpY - CameraDirY*CameraUpX

  DebugCameraRtX = DebugCameraDirY*DebugCameraUpZ - DebugCameraDirZ*DebugCameraUpY
  DebugCameraRtY = DebugCameraDirZ*DebugCameraUpX - DebugCameraDirX*DebugCameraUpZ
  DebugCameraRtZ = DebugCameraDirX*DebugCameraUpY - DebugCameraDirY*DebugCameraUpX
end
function RotateRight(theta)
  computeCameraRight()
  local X = CameraDirX
  local Y = CameraDirY
  local Z = CameraDirZ
  local DebugX = DebugCameraDirX
  local DebugY = DebugCameraDirY
  local DebugZ = DebugCameraDirZ

  
  local KdotCameraDir = CameraRtX*X + CameraRtY*Y + CameraRtZ*Z
  local KdotDebugCameraDir = DebugCameraRtX*DebugX + DebugCameraRtY*DebugY + DebugCameraRtZ*DebugZ
  if(DebugCam) then
    DebugCameraDirX = math.cos(theta)*DebugX + math.sin(theta)*(DebugCameraRtY*DebugZ-DebugCameraRtZ*DebugY)+ DebugCameraRtX*KdotDebugCameraDir*(1 - math.cos(theta))
    DebugCameraDirY = math.cos(theta)*DebugY + math.sin(theta)*(DebugCameraRtZ*DebugX-DebugCameraRtX*DebugZ)+ DebugCameraRtY*KdotDebugCameraDir*(1 - math.cos(theta))
    DebugCameraDirZ = math.cos(theta)*DebugZ + math.sin(theta)*(DebugCameraRtX*DebugY-DebugCameraRtY*DebugX)+ DebugCameraRtZ*KdotDebugCameraDir*(1 - math.cos(theta))
  else
    CameraDirX = math.cos(theta)*X + math.sin(theta)*(CameraRtY*Z-CameraRtZ*Y)+ CameraRtX*KdotCameraDir*(1 - math.cos(theta))
    CameraDirY = math.cos(theta)*Y + math.sin(theta)*(CameraRtZ*X-CameraRtX*Z)+ CameraRtY*KdotCameraDir*(1 - math.cos(theta))
    CameraDirZ = math.cos(theta)*Z + math.sin(theta)*(CameraRtX*Y-CameraRtY*X)+ CameraRtZ*KdotCameraDir*(1 - math.cos(theta))
  end
end
function keyHandler(keys)
  if keys.left then
    computeCameraRight()
    if(DebugCam) then
      DebugCameraPosX = DebugCameraPosX - targetFrameRate *frameVel * DebugCameraRtX;
      DebugCameraPosY = DebugCameraPosY - targetFrameRate *frameVel * DebugCameraRtY;
      DebugCameraPosZ = DebugCameraPosZ - targetFrameRate *frameVel * DebugCameraRtZ;
    else
      CameraPosX = CameraPosX - targetFrameRate *frameVel * CameraRtX;
      CameraPosY = CameraPosY - targetFrameRate *frameVel * CameraRtY;
      CameraPosZ = CameraPosZ - targetFrameRate *frameVel * CameraRtZ;
    end
  end
  if keys.right then
    computeCameraRight()
    if(DebugCam) then
      DebugCameraPosX = DebugCameraPosX + targetFrameRate *frameVel * DebugCameraRtX;
      DebugCameraPosY = DebugCameraPosY + targetFrameRate *frameVel * DebugCameraRtY;
      DebugCameraPosZ = DebugCameraPosZ + targetFrameRate *frameVel * DebugCameraRtZ;
    else
      CameraPosX = CameraPosX + targetFrameRate *frameVel * CameraRtX;
      CameraPosY = CameraPosY + targetFrameRate *frameVel * CameraRtY;
      CameraPosZ = CameraPosZ + targetFrameRate *frameVel * CameraRtZ;
    end
  end
  if keys.up then
    if(DebugCam) then
      DebugCameraPosX = DebugCameraPosX + targetFrameRate *frameVel * DebugCameraDirX;
      DebugCameraPosY = DebugCameraPosY + targetFrameRate *frameVel * DebugCameraDirY;
      DebugCameraPosZ = DebugCameraPosZ + targetFrameRate *frameVel * DebugCameraDirZ;
    else
      CameraPosX = CameraPosX + targetFrameRate *frameVel * CameraDirX;
      CameraPosY = CameraPosY + targetFrameRate *frameVel * CameraDirY;
      CameraPosZ = CameraPosZ + targetFrameRate *frameVel * CameraDirZ;
    end
  end
  -- Rotate
  if keys.down then
    --translateModel(dinoID,-0.1,0,0)
    if(DebugCam) then
      DebugCameraPosX = DebugCameraPosX - targetFrameRate *frameVel * DebugCameraDirX;
      DebugCameraPosY = DebugCameraPosY - targetFrameRate *frameVel * DebugCameraDirY;
      DebugCameraPosZ = DebugCameraPosZ - targetFrameRate *frameVel * DebugCameraDirZ;
    else
      CameraPosX = CameraPosX - targetFrameRate *frameVel * CameraDirX;
      CameraPosY = CameraPosY - targetFrameRate *frameVel * CameraDirY;
      CameraPosZ = CameraPosZ - targetFrameRate *frameVel * CameraDirZ;
    end
  end
  if keys.w then
    local theta = targetFrameRate *frameVel
    RotateRight(theta)
  end
  if keys.a then
    --translateModel(dinoID,0,0,-0.1)
    local X = CameraDirX
    local Z = CameraDirZ
    local DebugX = DebugCameraDirX
    local DebugZ = DebugCameraDirZ
    local theta = targetFrameRate * frameVel
    if(DebugCam) then
      DebugCameraDirX = math.cos(theta)*DebugX + math.sin(theta)*DebugZ
      DebugCameraDirZ = math.cos(theta)*DebugZ - math.sin(theta)*DebugX
    else
      CameraDirX = math.cos(theta)*X + math.sin(theta)*Z
      CameraDirZ = math.cos(theta)*Z - math.sin(theta)*X
    end
  end
  if keys.d then
    --translateModel(dinoID,0,0,0.1)
    local X = CameraDirX
    local Z = CameraDirZ
    local DebugX = DebugCameraDirX
    local DebugZ = DebugCameraDirZ
    local theta = targetFrameRate *frameVel
    if(DebugCam) then
      DebugCameraDirX = math.cos(theta)*DebugX - math.sin(theta)*DebugZ
      DebugCameraDirZ = math.cos(theta)*DebugZ + math.sin(theta)*DebugX
    else
      CameraDirX = math.cos(theta)*X - math.sin(theta)*Z
      CameraDirZ = math.cos(theta)*Z + math.sin(theta)*X
    end
  end
  if keys.s then
    local theta = -targetFrameRate *frameVel
    RotateRight(theta)
  end
  if keys.x then -- d open debug
    DebugCam = true
  end
  if keys.c then
    DebugCam = false -- x close debug
  end
end

for i= -1,1 do
  for j = -1,1 do
    teapotID = addModel("Teapot",i*modelsize,0,j*modelsize)
    -- setModelMaterial(teapotID,"Shiny Red Plastic")
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
animatedModels[dinoID] = true
velModel[dinoID] = {}
velModel[dinoID][1] = -0.01
velModel[dinoID][2] = 0.0
velModel[dinoID][3] = -0.01

RimID = addModel("Bigmax",0,0,0)
placeModel(RimID,-3.0,0.0,-1.5)
scaleModel(RimID,0.01,0.01,0.01)
animatedModels[RimID] = true
velModel[RimID] = {}
velModel[RimID][1] = 0.01
velModel[RimID][2] = 0.0
velModel[RimID][3] = 0.01

