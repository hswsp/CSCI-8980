--Rotation Example
print("Rotation Example")
print("-------------\nInstructions:")
print("Mouse over to swap rotations")
print("Mouse + z for Matrix Interpolation")
print("Mouse + tab for Quaternion Interpolation")
print("Mouse + shift for Normalized Quaternion Interpolation")
print("")
--Some useful webpages for working with quaternions
--https://www.andre-gaschler.com/rotationconverter/
--https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm

require "Rotate/KeyboardCamera" --Setup simple static camera
require "Rotate/QuaternionHelper" --Helper functions to assist in using quaternions

mouseLayer = 0 --A layer to put models we want the mouse to interact with

--Create two rotation matricies
A = {0.32, 0.55, 0.76, 0.0,    --An 130 deg (2.3 rad) rotation around axis (-0.77, -0.05, -0.63)
     -0.4, -0.64, 0.64, 1.5,   --   (I also set the position to: [0,1.5,0] to raise to model off the ground)
     0.85, -0.51, 0.02, 0, 
     0,0,0,1}
B = {1,0,0,0.0,                --An indentity rotation
     0,1,0,1.5,                --   (I also set the position to: [0,1.5,0] to raise to model off the ground)
     0,0,1,0,
     0,0,0,1}

--Create quaternions from matricies
QA = matrixToQuat(A)
QB = matrixToQuat(B)
print("QA: " .. quatToString(QA))
print("QB: " .. quatToString(QB))

--Linear interpolation
function lerp(A,B,t)
  local C = {}
  for i = 1,#A do
    C[i] = A[i] + t*(B[i]-A[i])
  end
  return C
end

--Normalize a quaternion by dividing by the squared-sum of components
function normalize(Q)
  local normedQ = {}
  local sum = math.sqrt(Q[1]*Q[1]+Q[2]*Q[2]+Q[3]*Q[3]+Q[4]*Q[4])
  for i = 1,#Q do
    normedQ[i] = Q[i]/sum
  end
  return normedQ
end

t = 0
function frameUpdate(dt)
  local model = intersectMouseWithLayer(mouseLayer) --See what our mouse is hovering over
  
  if model == teapotModel then --If the mouse is over the teapot...

    --Move the interpolation paramater forward in time (wrap if we hit 1)
    t = t + .5*dt
    if (t > 1) then
      t = 1
    end

    --Change how you interpolate rotation based on what key the user is pressing
    if lastKeys.shift then
      setModelTransform(model,quatToMatrix(normalize(lerp(QA,QB,t)))) --Much better! (Interpolate quaternions then normalize)
    elseif lastKeys.tab then
      setModelTransform(model,quatToMatrix(lerp(QA,QB,t))) --Okay (Interpolate quaternions)
    elseif lastKeys.z then
      setModelTransform(model,lerp(A,B,t)) --Bad (Interpolate matricies directly)
    else
      setModelTransform(model,B) --No interpolation
    end

  else --If our mouse moved off the teapot, the reset its rotation
    t = 0
    setModelTransform(teapotModel,A)
  end

end

--Save which keys the user has pressed to use in other functions
function keyHandler(keys)
  cameraUpdate(keys)
  lastKeys = keys
end

--Add floor model
floorModel = addModel("FloorPart",0,0,0)
placeModel(floorModel,0,-.04,0)
scaleModel(floorModel,20,1,20)
setModelMaterial(floorModel,"Flooring")

--Add teapot model
teapotModel = addModel("Teapot",-0.5,1.5,0)
addCollider(teapotModel,mouseLayer,1,0,0,0) --Register this model with the layer we intend to querry the mouse over
setModelMaterial(teapotModel,"Red Plastic")