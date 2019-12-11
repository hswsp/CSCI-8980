--Simple Example
print("Starting Lua for Simple Example")
require "CommonLibs/vec3"

CameraPosX = 0
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

ModelID = 0

row = 5
col = 5

animatedModels = {}
velModel = {}
rotYVelModel = {}

targetFrameRate = getTargetFPS();
CameraP = vec3(CameraPosX,CameraPosY,CameraPosZ);
CameraDir = vec3(CameraDirX,CameraDirY,CameraDirZ);
frameVel = 0.005
angleVel = 0.001
modelsize = 1

useFog = false
useFlame= false
useDissolve = false
-- function rotateY(v,theta)
--   local out
--   rotquat = quat(quat(math.cos(theta),0.-math.sin(theta),0),quat(0,1,0,0),
--             quat(math.sin(theta),0,math.cos(theta),0),quat(0,0,0,1))
--   vec3.rotate(v,rotquat,out)
--   return out
-- end
omiga = 0;
function frameUpdate(dt)
  for modelID,v in pairs(animatedModels) do
    --print("ID",modelID)
    local vel = velModel[modelID]
    if vel then
      omiga = omiga+ dt*vel
      translateModel(modelID, -vel*math.sin(omiga)*dt,0,vel*math.cos(omiga)*dt)
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
  if keys.shift then
    if  keys.up then
      CameraPosX = CameraPosX + targetFrameRate *frameVel * CameraUpX;
      CameraPosY = CameraPosY + targetFrameRate *frameVel * CameraUpY;
      CameraPosZ = CameraPosZ + targetFrameRate *frameVel * CameraUpZ; 
    end
  
    if keys.down then
      CameraPosX = CameraPosX - targetFrameRate *frameVel * CameraUpX;
      CameraPosY = CameraPosY - targetFrameRate *frameVel * CameraUpY;
      CameraPosZ = CameraPosZ - targetFrameRate *frameVel * CameraUpZ; 
    end
  else
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
      -- SetModelDissolve(ModelID)
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

    if keys.q then
      useFlame = true
    end

    if keys.z then
      useFlame = false
    end
  end
end


addModel("Barrel",2,0.5,0);
addModel("Boulder",-5,1,0);
addModel("Terrain",0,0,0); 
addModel("Windmill",-10.6,0.5,12.11);
TurtleID = addModel("Turtles",-16.5,0.1,16.1);
addModel("Trees",0,0.1,0);
RimID = addModel("Bridge",0,0.1,6);
scaleModel(RimID,1.5,1.5,1.5)
addModel("Houses",-13,0.1,5);
crateID = addModel("Crate",-10,1.5,-10);
scaleModel(crateID,0.03,0.03,0.03)


--Add several predefined models to be rendered
-- i = 1 --Lau is typically 1-indexed
-- model = {}
-- model[i] = addModel("Windmill",-2,.5,-3);
-- setModelMaterial (model[i],"Dark Polished Wood")
-- i = i+1
-- model[i] = addModel("Bookcase",0,1,0); i = i+1
-- model[i] = addModel("Ring",0,0.5,0); 
-- i = i+1
-- model[i] = addModel("Soccer Ball",0,1,0); i = i+1
-- model[i] = addModel("Thonet S43 Chair",0,1,0); i = i+1
-- model[i] = addModel("Silver Knot",0,1,0); i = i+1
-- model[i] = addModel("Gold Knot",0,1,0); i = i+1
-- model[i] = addModel("Frog",0,1,0); i = i+1
-- model[i] = addModel("Copper Pan",0,1,0); i = i+1
-- model[i] = addModel("Pool Table",0,1,0); i = i+1

--Choose 1 model to be drawn at a time, the rest will be hidden
-- drawModel = 1
-- for i = 1,#model do
--   if drawModel ~= i then
--     hideModel(model[i])
--   end
-- end

--Set the 3rd model to rotate around it's the y-axis
rotYVelModel[TurtleID] = 0.2  --radians per second
-- velModel[TurtleID] = {}
-- velModel[TurtleID][1] = -0.1
-- velModel[TurtleID][2] = 0.0
-- velModel[TurtleID][3] = -0.1
velModel[TurtleID] = -0.01
animatedModels[TurtleID] = true




-- dinoID = addModel("Dino",0,0,-.15)
-- animatedModels[dinoID] = true


-- RimID = addModel("Bigmax",0,0,0)
-- placeModel(RimID,-3.0,0.0,-1.5)
-- scaleModel(RimID,0.01,0.01,0.01)
-- animatedModels[RimID] = true
-- velModel[RimID] = {}
-- velModel[RimID][1] = 0.1
-- velModel[RimID][2] = 0.0
-- velModel[RimID][3] = 0.1

