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
t = 0
horsePos = {15,-1.8}
theta = 0
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
  -- horsePos = horsePos + 1*dt*speed[curAction]
  t = t + dt
  if t > 1 then
    t = t-1
  end 
  wHorse = 0.1
  theta = theta+dt*wHorse
  horsePos[1] = 13 + 3*speed[curAction]*math.cos(theta)
  horsePos[2] = -2.5 + 3*speed[curAction]*math.sin(theta)
  translateModel(horse[curAction],-3*wHorse*math.sin(theta)*dt,0,3*wHorse*math.cos(theta)*dt)
  -- placeModel(horse[curAction],horsePos[1],0,horsePos[2])
  selectChild(horse[curAction],t)
  rotateModel(horse[curAction],-wHorse*dt, 0, 1, 0)



  rotateModel(crateID,3*wHorse*dt, 0, 1, 0)
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

     --When tab is pressed hide the current animation and unhide the next one
    if keys.tab and not tabDownBefore then
      t = 0
      hideModel(horse[curAction])
      curAction = (curAction % #horse) + 1
      unhideModel(horse[curAction])
    end
    tabDownBefore = keys.tab --Needed so that single tab press only counts once

    if keys.r then --Reset Position
      horsePos = -5
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
addModel("Bench",1.29,0.0,-3);
addModel("Bushes",0.0,0.0,0.0);--11.29,0.0,-9
CTID = addModel("CuteTrees",10.29,0.0,-5);
scaleModel(CTID,2,2,2)
addModel("Fences",8.29,0.0,-5);
addModel("Foxes",16.29,0.0,-9.5);
addModel("HerbStall",4.00,0.0,-9.5);
addModel("Lanterns",-11,0.0,-0.5);
addModel("LillyPads",-19,0.0,3);
addModel("Mushrooms",2.20,0.0,0.0);
addModel("Rocks",2.20,0.0,0.0);
addModel("Statue",5.50,0.0,-5.8);
addModel("Barrels",0,0.0,0);


--Set the 3rd model to rotate around it's the y-axis
rotYVelModel[TurtleID] = 0.2  --radians per second
velModel[TurtleID] = -0.01
animatedModels[TurtleID] = true

--Load various animated models of horse actions
i = 1 --Lau is typically 1-indexed
horse = {}
speed = {}
horse[i] = addModel("Horse-Walk",13,0,-1.8); speed[i] = 1.1; i = i+1
horse[i] = addModel("Horse-Dash",13,0,-1.8); speed[i] = 3.0; i = i+1
horse[i] = addModel("Horse-Jump",13,0,-1.8); speed[i] = 1.2; i = i+1 --No one velocity is right!
horse[i] = addModel("Horse-Fall",13,0,-1.8); speed[i] = 0.0; i = i+1

--Only draw one of the actions
curAction = 1
for i = 1,#horse do
  if curAction ~= i then
    hideModel(horse[i])
  end
end



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

