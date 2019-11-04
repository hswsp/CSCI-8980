print("Animated Dino Example")

--These 9 special variables are querried by the engine each
-- frame and used to set the camera pose.
--Here we set the intial camera pose:
CameraPosX = -4.0; CameraPosY = 2; CameraPosZ = -1.8
CameraDirX = 1.0; CameraDirY = -0.2; CameraDirZ = 0.4
CameraUpX = 0.0; CameraUpY = 1.0; CameraUpZ = 0.0

theta = 0; radius = 4 --Helper variabsle for camrea control

--Special function that is called every frame
--The variable dt containts how much times has pased since it was last called
t = 0
speed = 1.0
function frameUpdate(dt)

  --Update the camera based on radius and theta
  CameraPosX = radius*math.cos(theta)
  CameraPosZ = radius*math.sin(theta)
  CameraDirX = -CameraPosX
  CameraDirZ = -CameraPosZ

  t = t + dt*speed
  if t > 1 then
    t = t-1 --Smart update from Zach :)
  end
  selectChild(dino,t)

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
end

--Add base floor model
floor = addModel("Floor",0,.95,0)
setModelMaterial(floor,"Flooring")

dino = addModel("Dino",0,1,0)

