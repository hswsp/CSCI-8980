--Basic example for model loading, keyboad interaction, a script-based animation
print("Starting Lua script for Viewing Dino Models")

--Todo:
-- Lua modules (for better organization, and maybe reloading?)

--These 9 special variables are querried by the engine each
-- frame and used to set the camera pose.
--Here we set the intial camera pose:
CameraPosX = -4.0; CameraPosY = 2; CameraPosZ = -1.8
CameraDirX = 1.0; CameraDirY = -0.2; CameraDirZ = 0.4
CameraUpX = 0.0; CameraUpY = 1.0; CameraUpZ = 0.0

theta = 0; radius = 4 --Helper variabsle for camrea control


--Special function that is called every frame
--The variable dt containts how much times has pased since it was last called
function frameUpdate(dt)

  --Update the camera based on radius and theta
  CameraPosX = radius*math.cos(theta)
  CameraPosZ = radius*math.sin(theta)
  CameraDirX = -CameraPosX
  CameraDirZ = -CameraPosZ

end

--Special function that is called each frame. The variable
--keys containts information about which keys are currently .
function keyHandler(keys)

  --Move camera radius and theta based on up/down/left/right keys
  if keys.left then
    theta = theta + .03
  end
  if keys.right then
    theta = theta - .03
  end
  if keys.up then
    radius = radius - .05
  end
  if keys.down then
    radius = radius + .05
  end

  --Tab key cycles through models unhideing them from rendering one by one
  if keys.tab then
    hideModel(model[drawModel])
    if keys.shift then --Shift-tab cycles backwards
      drawModel = (drawModel -1 % #model)
      if drawModel == 0 then drawModel = #model end
    else
      drawModel = (drawModel % #model) + 1
    end
    unhideModel(model[drawModel])
  end

end

--Add base floor model
floor = addModel("Floor",0,.95,0)
setModelMaterial(floor,"Flooring")

--Add several predefined models to be rendered
i = 1 --Lau is typically 1-indexed
model = {}
model[i] = addModel("Dino1",0,1,0); i = i+1
model[i] = addModel("Dino2",0,1,0); i = i+1
model[i] = addModel("Dino3",0,1,0); i = i+1
model[i] = addModel("Dino4",0,1,0); i = i+1
model[i] = addModel("Dino5",0,1,0); i = i+1
model[i] = addModel("Dino6",0,1,0); i = i+1
model[i] = addModel("Dino7",0,1,0); i = i+1
model[i] = addModel("Dino8",0,1,0); i = i+1
model[i] = addModel("Dino9",0,1,0); i = i+1
model[i] = addModel("Dino10",0,1,0); i = i+1
model[i] = addModel("Dino11",0,1,0); i = i+1
model[i] = addModel("Dino12",0,1,0); i = i+1
model[i] = addModel("Dino13",0,1,0); i = i+1
model[i] = addModel("Dino14",0,1,0); i = i+1
model[i] = addModel("Dino15",0,1,0); i = i+1
model[i] = addModel("Dino16",0,1,0); i = i+1
model[i] = addModel("Dino17",0,1,0); i = i+1
model[i] = addModel("Dino18",0,1,0); i = i+1
model[i] = addModel("Dino19",0,1,0); i = i+1
model[i] = addModel("Dino20",0,1,0); i = i+1
model[i] = addModel("Dino21",0,1,0); i = i+1
model[i] = addModel("Dino22",0,1,0); i = i+1
model[i] = addModel("Dino23",0,1,0); i = i+1
model[i] = addModel("Dino24",0,1,0); i = i+1
model[i] = addModel("Dino25",0,1,0); i = i+1
model[i] = addModel("Dino26",0,1,0); i = i+1
model[i] = addModel("Dino27",0,1,0); i = i+1
model[i] = addModel("Dino28",0,1,0); i = i+1
model[i] = addModel("Dino29",0,1,0); i = i+1
model[i] = addModel("Dino30",0,1,0); i = i+1
model[i] = addModel("Dino31",0,1,0); i = i+1
model[i] = addModel("Dino32",0,1,0); i = i+1
model[i] = addModel("Dino33",0,1,0); i = i+1



--Choose 1 model to be drawn at a time, the rest will be hidden
drawModel = 1
for i = 1,#model do
  if drawModel ~= i then
    hideModel(model[i])
  end
end
