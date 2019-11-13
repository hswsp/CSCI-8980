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


row = 5
col = 5

animatedModels = {}
velModel = {}
rotYVelModel = {}

targetFrameRate = getTargetFPS();
CameraP = vec3(CameraPosX,CameraPosY,CameraPosZ);
CameraDir = vec3(CameraDirX,CameraDirY,CameraDirZ);
frameVel = 0.001
angleVel = 0.001
modelsize = 1

useFog = false
useDissolve = false
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
      translateModel(modelID, -vel[1]*math.sin(dt*vel[1])*dt,dt*vel[2],vel[3]*math.cos(dt*vel[3])*dt)
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

end
function RotateRight(theta)
  computeCameraRight()
  local X = CameraDirX
  local Y = CameraDirY
  local Z = CameraDirZ
  local UX = CameraUpX
  local UY = CameraUpY
  local UZ = CameraUpZ

  local KdotCameraRight = CameraRtX*X + CameraRtY*Y + CameraRtZ*Z
  CameraDirX = math.cos(theta)*X + math.sin(theta)*(CameraRtY*Z-CameraRtZ*Y)+ CameraRtX*KdotCameraRight*(1 - math.cos(theta))
  CameraDirY = math.cos(theta)*Y + math.sin(theta)*(CameraRtZ*X-CameraRtX*Z)+ CameraRtY*KdotCameraRight*(1 - math.cos(theta))
  CameraDirZ = math.cos(theta)*Z + math.sin(theta)*(CameraRtX*Y-CameraRtY*X)+ CameraRtZ*KdotCameraRight*(1 - math.cos(theta))
  
  KdotCameraRight = CameraRtX*UX + CameraRtY*UY + CameraRtZ*UZ
  CameraUpX = math.cos(theta)*UX + math.sin(theta)*(CameraRtY*UZ-CameraRtZ*UY)+ CameraRtX*KdotCameraRight*(1 - math.cos(theta))
  CameraUpY = math.cos(theta)*UY + math.sin(theta)*(CameraRtZ*UX-CameraRtX*UZ)+ CameraRtY*KdotCameraRight*(1 - math.cos(theta))
  CameraUpZ = math.cos(theta)*UZ + math.sin(theta)*(CameraRtX*UY-CameraRtY*UX)+ CameraRtZ*KdotCameraRight*(1 - math.cos(theta))
end
function RotateUp(theta)
  
  local X = CameraDirX
  local Y = CameraDirY
  local Z = CameraDirZ
  local KdotCameraUp = CameraUpX*X + CameraUpY*Y + CameraUpZ*Z
  CameraDirX = math.cos(theta)*X + math.sin(theta)*(CameraUpY*Z-CameraUpZ*Y)+ CameraUpX*KdotCameraUp*(1 - math.cos(theta))
  CameraDirY = math.cos(theta)*Y + math.sin(theta)*(CameraUpZ*X-CameraUpX*Z)+ CameraUpY*KdotCameraUp*(1 - math.cos(theta))
  CameraDirZ = math.cos(theta)*Z + math.sin(theta)*(CameraUpX*Y-CameraUpY*X)+ CameraUpZ*KdotCameraUp*(1 - math.cos(theta))
  computeCameraRight()
end
function keyHandler(keys)
  if keys.left then
    computeCameraRight()
    CameraPosX = CameraPosX - targetFrameRate *frameVel * CameraRtX;
    CameraPosY = CameraPosY - targetFrameRate *frameVel * CameraRtY;
    CameraPosZ = CameraPosZ - targetFrameRate *frameVel * CameraRtZ;
 
  end
  if keys.right then
    computeCameraRight()
    CameraPosX = CameraPosX + targetFrameRate *frameVel * CameraRtX;
    CameraPosY = CameraPosY + targetFrameRate *frameVel * CameraRtY;
    CameraPosZ = CameraPosZ + targetFrameRate *frameVel * CameraRtZ;
 
  end
  if keys.up then
    CameraPosX = CameraPosX + targetFrameRate *frameVel * CameraDirX;
    CameraPosY = CameraPosY + targetFrameRate *frameVel * CameraDirY;
    CameraPosZ = CameraPosZ + targetFrameRate *frameVel * CameraDirZ;
  end
  if keys.down then
    CameraPosX = CameraPosX - targetFrameRate *frameVel * CameraDirX;
    CameraPosY = CameraPosY - targetFrameRate *frameVel * CameraDirY;
    CameraPosZ = CameraPosZ - targetFrameRate *frameVel * CameraDirZ; 
  end

  if keys.w then
    local theta = targetFrameRate *angleVel
    RotateRight(theta)
  end
  if keys.a then
    local X = CameraDirX
    local Z = CameraDirZ
    local theta = targetFrameRate * angleVel
    RotateUp(theta)
  end
  if keys.d then
    local X = CameraDirX
    local Z = CameraDirZ
    local theta = targetFrameRate *angleVel
    RotateUp(-theta)
  end
  if keys.s then
    local theta = -targetFrameRate *angleVel
    RotateRight(theta)
  end
  if keys.x then -- d open debug
    useDissolve = true
  end
  if keys.c then
    useDissolve = false -- x close debug
  end

  if keys.f then
    useFog = true
  end

  if keys.v then
    useFog = false
  end
end

for i= -row,row do
  for j = -col,col do
    teapotID = addModel("Teapot",i*modelsize,0,j*modelsize)
    setModelMaterial(teapotID,"Shiny Red Plastic")
    -- setModelMaterial(teapotID,"Steel")
    animatedModels[teapotID] = true
    rotYVelModel[teapotID] = 1
  end
end


for i = -row ,row do
  for j = -col,col do
      floorID = addModel("FloorPart",0,0,0)
      floorColID = addCollider(floorID,0,0.5,0,0,0) --layer 0 for floor
      scaleModel(floorID,3,1,3)
      placeModel(floorID,i,-.02,j)
      
      if (i+j)%2==0 then
          setModelMaterial (floorID,"Polished Wood")
      else
          setModelMaterial (floorID,"Dark Polished Wood")
      end
  end
end

--Add several predefined models to be rendered
i = 1 --Lau is typically 1-indexed
model = {}
model[i] = addModel("Windmill",0,1,0); i = i+1
model[i] = addModel("Bookcase",0,1,0); i = i+1
model[i] = addModel("Ring",0,1,0); 
i = i+1
model[i] = addModel("Soccer Ball",0,1,0); i = i+1
model[i] = addModel("Thonet S43 Chair",0,1,0); i = i+1
model[i] = addModel("Silver Knot",0,1,0); i = i+1
model[i] = addModel("Gold Knot",0,1,0); i = i+1
model[i] = addModel("Frog",0,1,0); i = i+1
model[i] = addModel("Copper Pan",0,1,0); i = i+1
model[i] = addModel("Pool Table",0,1,0); i = i+1

--Choose 1 model to be drawn at a time, the rest will be hidden
drawModel = 3
for i = 1,#model do
  if drawModel ~= i then
    hideModel(model[i])
  end
end

--Set the 3rd model to rotate around it's the y-axis
rotYVelModel[model[3]] = 0.2  --radians per second
animatedModels[model[3]] = true




-- dinoID = addModel("Dino",0,0,-.15)
-- animatedModels[dinoID] = true
-- velModel[dinoID] = {}
-- velModel[dinoID][1] = -0.1
-- velModel[dinoID][2] = 0.0
-- velModel[dinoID][3] = -0.1

-- RimID = addModel("Bigmax",0,0,0)
-- placeModel(RimID,-3.0,0.0,-1.5)
-- scaleModel(RimID,0.01,0.01,0.01)
-- animatedModels[RimID] = true
-- velModel[RimID] = {}
-- velModel[RimID][1] = 0.1
-- velModel[RimID][2] = 0.0
-- velModel[RimID][3] = 0.1

