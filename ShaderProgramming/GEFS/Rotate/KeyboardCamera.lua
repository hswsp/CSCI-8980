--Camera Deafult parameters
CameraPosX = 2.3
CameraPosY = 2.0
CameraPosZ = 3.2

CameraDirX = -0.63
CameraDirY = -0.2
CameraDirZ = -0.77

CameraUpX = 0.0
CameraUpY = 1.0
CameraUpZ = 0.0


--Update camera based on key press (arrows or WASD)
ang = math.atan(-CameraDirZ,CameraDirX)
function cameraUpdate(keys)
  if keys.left or keys.a then
    ang = ang + .02
  end
  if keys.right or keys.d then
    ang = ang - .02
  end
  if keys.up or keys.w then
    CameraPosX = CameraPosX + .1*CameraDirX
    CameraPosZ = CameraPosZ + .1*CameraDirZ
  end
  if keys.down or keys.s then
    CameraPosX = CameraPosX - .1*CameraDirX
    CameraPosZ = CameraPosZ - .1*CameraDirZ
  end
  CameraDirX = math.cos(ang);
  CameraDirZ = -math.sin(ang);
end