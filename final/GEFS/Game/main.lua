Init = require "Game/Init"
Finish = require "Game/End"

require "Game/Animation"

s_background=loadAudio("audio/wangzherongyao.wav")
s_fail=loadAudio("audio/E-Mu-Proteus-FX-Pianotar-C3.wav")
s_click=loadAudio("audio/1980s-Casio-Organ-C5.wav")
s_win=loadAudio("audio/Alesis-Sanctuary-QCard-Crotales-C6.wav")

playSong(s_background)
currenttime=0
GameContrl = 0
InitialEndflag = false 

HasElimination = false
TrychangeBack = false
CameraPosX = -5.0
CameraPosY = 5.0
CameraPosZ = 0.0

CameraDirX = 1.0*math.sin(math.pi/4)
CameraDirY = -1.0*math.cos(math.pi/4)
CameraDirZ = -0.0

CameraUpX = 1.0*math.cos(math.pi/4)
CameraUpY = 1.0*math.sin(math.pi/4)
CameraUpZ = 0.0


mouse = {
  px,py,  
  x = 0,y = 0,
  right,left,middle,
}
mouse_released = true
targetFrameRate = getTargetFPS();
frameVel = 0.005
angleVel = 0.001
currentchange={
  a,b,c,
  d,e,f,
  first_i,first_j, -- index for model array
  second_i,second_j,  
  -- the (i,j) only track the tile not the animal
  state = 0,
  modelIDA,
  modelIDB
}
useFog = false
useDissolve = false
-- camera 
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

  local KdotCameraDir = CameraRtX*X + CameraRtY*Y + CameraRtZ*Z
  CameraDirX = math.cos(theta)*X + math.sin(theta)*(CameraRtY*Z-CameraRtZ*Y)+ CameraRtX*KdotCameraDir*(1 - math.cos(theta))
  CameraDirY = math.cos(theta)*Y + math.sin(theta)*(CameraRtZ*X-CameraRtX*Z)+ CameraRtY*KdotCameraDir*(1 - math.cos(theta))
  CameraDirZ = math.cos(theta)*Z + math.sin(theta)*(CameraRtX*Y-CameraRtY*X)+ CameraRtZ*KdotCameraDir*(1 - math.cos(theta))

  CameraUpX = math.cos(theta)*UX + math.sin(theta)*(CameraRtY*UZ-CameraRtZ*UY)+ CameraRtX*KdotCameraDir*(1 - math.cos(theta))
  CameraUpY = math.cos(theta)*UY + math.sin(theta)*(CameraRtZ*UX-CameraRtX*UZ)+ CameraRtY*KdotCameraDir*(1 - math.cos(theta))
  CameraUpZ = math.cos(theta)*UZ + math.sin(theta)*(CameraRtX*UY-CameraRtY*UX)+ CameraRtZ*KdotCameraDir*(1 - math.cos(theta))
end

function RotateUp(theta)
  computeCameraRight()
  local X = CameraDirX
  local Y = CameraDirY
  local Z = CameraDirZ
  local KdotCameraUp = CameraUpX*X + CameraUpY*Y + CameraUpZ*Z
  CameraDirX = math.cos(theta)*X + math.sin(theta)*(CameraUpY*Z-CameraUpZ*Y)+ CameraUpX*KdotCameraUp*(1 - math.cos(theta))
  CameraDirY = math.cos(theta)*Y + math.sin(theta)*(CameraUpZ*X-CameraUpX*Z)+ CameraUpY*KdotCameraUp*(1 - math.cos(theta))
  CameraDirZ = math.cos(theta)*Z + math.sin(theta)*(CameraUpX*Y-CameraUpY*X)+ CameraUpZ*KdotCameraUp*(1 - math.cos(theta))
end
-- keyboard
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
    -- CameraDirX = math.cos(theta)*X + math.sin(theta)*Z
    -- CameraDirZ = math.cos(theta)*Z - math.sin(theta)*X
    RotateUp(theta)
  end
  if keys.d then
    local X = CameraDirX
    local Z = CameraDirZ
    local theta = targetFrameRate *angleVel
    -- CameraDirX = math.cos(theta)*X - math.sin(theta)*Z
    -- CameraDirZ = math.cos(theta)*Z + math.sin(theta)*X
    RotateUp(-theta)
  end
  if keys.s then
    local theta = -targetFrameRate *angleVel
    RotateRight(theta)
  end
end


function frameUpdate(dt)

  -- print(GameContrl)
  if GameContrl == 1 then
    -- for modelID,v in pairs(StartModels) do
    --   hideModel(modelID)
    -- end
    
    if(HasElimination == true) then  
      Logic:adjustment()
    else 
      swapAnimals() 
    end
    for modelID,v in pairs(animatedModels) do
      local vel = velModel[modelID]
      if vel then 
        translateModel(modelID,dt*vel[1],dt*vel[2],dt*vel[3])
      end

      local rotYvel = rotYVelModel[modelID]
      if rotYvel then 
        rotateModel(modelID,rotYvel*dt, 0, 1, 0)
      end
    end

    for modelID,v in pairs(Anim) do
      if(v.Isstretch) then
        v:bounce()
      end
      if(v.Isjumping) then
        v:jump()
      end
      time=pushcontrol()
      if time==10 then
        useDissolve = true
        useFog = false
      elseif time==0 then
        useFog = true  
      end
      if time==20 and InitialEndflag == false then
        CameraPosX = 0.0
        CameraPosY = 2.5
        CameraPosZ = -7.0
      
        CameraDirX = 0.0
        CameraDirY = 0.0
        CameraDirZ = 1.0
      
        CameraUpX = 0.0
        CameraUpY = 1.0
        CameraUpZ = 0.0
        Deletegame()
        GameContrl = 2
        Finish:EndInterface()
        InitialEndflag = true
       end
      
    end


  elseif  GameContrl == 0 then
    for modelID,v in pairs(StartModels) do
      -- local vel = velModel[modelID]
      -- if vel then 
      --   translateModel(modelID,dt*vel[1],dt*vel[2],dt*vel[3])
      -- end

      local rotYvel = rotYVelModel[modelID]
      local thetaMax = 180*math.pi/180
      rotateModel(modelID,rotYvel*dt, 1, 0, 0)
      StartModelAngles[modelID] = StartModelAngles[modelID] + rotYvel*dt
      if(StartModelAngles[modelID]> thetaMax and rotYVelModel[modelID]>0) then
        rotYVelModel[modelID] = -rotYVelModel[modelID]
      elseif(StartModelAngles[modelID]< -thetaMax and rotYVelModel[modelID]<0) then
        rotYVelModel[modelID] = -rotYVelModel[modelID]
      end

    end
  elseif  GameContrl == 2 then
    useFog = false
    useDissolve = false
    local velX = -1
    for modelID,v in pairs(Objectid) do
      if(ObjdeltPox[modelID] <= 5) then
        translateModel(modelID,dt*velX,0,0)
        ObjdeltPox[modelID] = math.abs(dt*velX) + ObjdeltPox[modelID]
      end
    end 
    for modelID,v in pairs(NumberObjID) do
      local rotZvel = 1
      if(ObjdeltPox[modelID] <= 5) then
        translateModel(modelID,dt*velX,0,0)
        ObjdeltPox[modelID] = math.abs(dt*velX) + ObjdeltPox[modelID]
        rotateModel(modelID,rotZvel*dt, 0, 0, 1)
      else
        rotateModel(modelID,rotZvel*dt, 0, 0, -1)

        local scaleVel = 1
        if(Numberenlarg[modelID]) then
          local enlarge = 1 + scaleVel*dt
          scaleModel(modelID,enlarge,enlarge,0) 
          Numbersize[modelID] = Numbersize[modelID]*enlarge
          if(Numbersize[modelID] >=1.6) then
            Numberenlarg[modelID] = false
          end
        else
          local enlarge = 1 - scaleVel*dt
          scaleModel(modelID,enlarge,enlarge,0) 
          Numbersize[modelID] = Numbersize[modelID]*enlarge
          if(Numbersize[modelID] <=0.5) then
            Numberenlarg[modelID] = true
          end
        end

      end
    end

  end

end

function switchModel(dt)
  -- if(Anim[currentchange.modelIDA].Isthrow and Anim[currentchange.modelIDB].Isthrow) then
  --   Anim[currentchange.modelIDA]:computeThrow(currentchange.modelIDB,dt)
  -- elseif((not Anim[currentchange.modelIDA].Isthrow) and Anim[currentchange.modelIDB].Isthrow) then
  --   Anim[currentchange.modelIDB]:computeThrow(currentchange.modelIDA,dt)
  -- jump together
  if(Anim[currentchange.modelIDA].Isthrow or Anim[currentchange.modelIDB].Isthrow) then
    Anim[currentchange.modelIDA]:computeThrow(currentchange.modelIDB)
    Anim[currentchange.modelIDB]:computeThrow(currentchange.modelIDA)
  elseif(TrychangeBack) then
    if(IsCurchangeValid()) then 
      -- if(useDissolve==false) then
      Tryswap() -- do swap 
      playSoundEffect(s_win) 
        -- print("222222222") 
      -- end
      -- print("11111111111")
      HasElimination = true   
      Logic:adjustment()
    
    else
      -- swap false
      playSoundEffect(s_fail)
      Anim[currentchange.modelIDA]:InitThrow(currentchange.modelIDB)
      Anim[currentchange.modelIDB]:InitThrow(currentchange.modelIDA)
      TrychangeBack = false
    end
    
  else 
    -- finish swap
    Resetclicked()
    currentchange.modelIDA=nil
    currentchange.modelIDB=nil


  end
  
  
  
end

function canSwitch()
  if(currentchange.a==currentchange.d and -1.1< currentchange.c-currentchange.f 
  and currentchange.c-currentchange.f<1.1) then 
    return true
  elseif(-1.1<currentchange.a-currentchange.d and currentchange.a-currentchange.d<1.1 
  and currentchange.c==currentchange.f) then
    return true
  else
    return false
  end

end

function Tryswap()
  LinkBoard[currentchange.first_i][currentchange.first_j],LinkBoard[currentchange.second_i][currentchange.second_j]
  = LinkBoard[currentchange.second_i][currentchange.second_j],LinkBoard[currentchange.first_i][currentchange.first_j]
  ModelIDArr[currentchange.first_i][currentchange.first_j],ModelIDArr[currentchange.second_i][currentchange.second_j]
  = ModelIDArr[currentchange.second_i][currentchange.second_j],ModelIDArr[currentchange.first_i][currentchange.first_j]
end

function IsCurchangeValid() 
  -- try swap
  Tryswap()
  local Elim1 = Logic:remove(currentchange.first_i,currentchange.first_j,LinkBoard[currentchange.first_i][currentchange.first_j])
  local Elim2 = Logic:remove(currentchange.second_i,currentchange.second_j,LinkBoard[currentchange.second_i][currentchange.second_j])
  Tryswap() -- swap back
  if Elim1 or Elim2 then
    return true
  else
    return false
  end
end

function Resetclicked()
  rotYVelModel[currentchange.modelIDA] = 0
  rotYVelModel[currentchange.modelIDB] = 0
end

function swapAnimals()
  -- swap animals
  if currentchange.state==2 then
    if(canSwitch()) then
      switchModel(dt)
    else
      Resetclicked()
      currentchange.modelIDA = nil
      currentchange.modelIDB = nil
    end
    if(currentchange.modelIDA==nil and currentchange.modelIDB ==nil) then
      currentchange.state = 0 
    end
    
  end

end




function mouseHandler(mouse)
  
    if(not mouse.left) then
      mouse_released = true

    elseif(mouse.left and mouse_released) then -- make sure the first time clicked

      if(GameContrl == 1) then
        -- the object layer
        local hitmodelID, hitmodelDIst = intersectMouseWithLayer(1)   
        -- the board layer
        local hittileID, hittileDIst = intersectMouseWithLayer(0)
        local curMID = nil
        -- add model on the tile
        if(hittileID ~=nil and hitmodelID ~= nil and currentchange.state==0 
        and currentchange.modelIDB ~=hitmodelID) then
          currentchange.first_i,y,currentchange.first_j = getModelPos(hittileID)
          currentchange.modelIDA = ModelIDArr[currentchange.first_i][currentchange.first_j]
          curMID = currentchange.modelIDA 
          currentchange.a,currentchange.b,currentchange.c= getModelPos( currentchange.modelIDA)
          currentchange.state=1
          -- currentchange.a,currentchange.b,currentchange.c= getModelPos(hitmodelID)
          -- currentchange.modelIDA=hitmodelID
          if(curMID ~= nil and currentchange.state~=2 ) then
            rotYVelModel[curMID] = 1
            playSoundEffect(s_click)
          end
        elseif(hittileID ~=nil and hitmodelID ~= nil and currentchange.state==1 and 
        currentchange.modelIDA ~=hitmodelID)then
          currentchange.second_i,y,currentchange.second_j = getModelPos(hittileID)
          currentchange.modelIDB = ModelIDArr[currentchange.second_i][currentchange.second_j]
          curMID = currentchange.modelIDB
          currentchange.d,currentchange.e,currentchange.f= getModelPos(currentchange.modelIDB)
          -- currentchange.d,currentchange.e,currentchange.f= getModelPos(hitmodelID)
          -- currentchange.modelIDB=hitmodelID
          -- swap the model array
          Anim[currentchange.modelIDA]:InitThrow(currentchange.modelIDB)
          Anim[currentchange.modelIDB]:InitThrow(currentchange.modelIDA)
          TrychangeBack = true
          if(curMID ~= nil and currentchange.state~=2 ) then
            rotYVelModel[curMID] = 1
            playSoundEffect(s_click)
          end
          currentchange.state=2

        end 
        
      elseif GameContrl ==0 then
        local hitmodelID, hitmodelDIst = intersectMouseWithLayer(1)
        if(hitmodelID ~= nil) then
          InitGame()
          GameContrl = 1
          
          -- currenttime= os.clock()
          -- print(currenttime)
            end
      end


      mouse_released = false

    end
    if(mouse.right) then
      hitmodelID, hitmodelDIst = intersectMouseWithLayer(1)
      if(hitmodelID~=nil) then
        rotYVelModel[hitmodelID] = -1
        setModelMaterial(hitmodelID,"Shiny Red Plastic")
      end
    end

    if(mouse.middle) then

    end

end




-- Initial the checkboard
if GameContrl==1 then
  InitGame()
elseif GameContrl==0 then
  CameraPosX = 0.0
  CameraPosY = 2.5
  CameraPosZ = -7.0

  CameraDirX = 0.0
  CameraDirY = 0.0
  CameraDirZ = 1.0

  CameraUpX = 0.0
  CameraUpY = 1.0
  CameraUpZ = 0.0
  Init:StartInterface()
end



function InitGame()
  CameraPosX = -5.0
  CameraPosY = 5.0
  CameraPosZ = 0.0

  CameraDirX = 1.0*math.sin(math.pi/4)
  CameraDirY = -1.0*math.cos(math.pi/4)
  CameraDirZ = -0.0

  CameraUpX = 1.0*math.cos(math.pi/4)
  CameraUpY = 1.0*math.sin(math.pi/4)
  CameraUpZ = 0.0
  DeleteStart()
  Init:InitCheckBoard()
  SetSkyBox("./SkyBoxes/Organic/")
end


function DeleteStart()
  for modelID,v in pairs(StartModels) do
    deleteModel(modelID)
  end
end

function Deletegame()
  for i = -row,row do
    for j = -col,col do
      if(ModelIDArr[i][j]~=nil) then
        deleteModel(ModelIDArr[i][j])
      end
    end
  end
end

