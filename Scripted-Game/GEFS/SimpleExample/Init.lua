Game = require "SimpleExample/GameLogic"
Logic = Game:new()
animatedModels = {}
StartModels = {}
velModel = {}
rotYVelModel = {}
StartModelAngles = {}

local Init = {}
function Init:InitCheckBoard()
    for i = -row ,row do
        LinkBoard[i] = {}
        ModelIDArr[i] = {}
        state[i] = {}
        for j = -col,col do
            floorID = addModel("FloorPart",0,0,0)
            floorColID = addCollider(floorID,0,0.5,0,0,0) --layer 0 for floor
            scaleModel(floorID,3,1,3)
            placeModel(floorID,i,-.02,j)
            
            if (i+j)%2==0 then
                setModelMaterial (floorID,"Polished Wood")
            else
                setModelMaterial (floorID,"Clay")
            end
        end
    end

    math.randomseed(os.time())
    -- init 2D array
    for i = -row,row do
        for j = -col,col do
            LinkBoard[i][j] = "nil"
            ModelIDArr[i][j] = nil
            state[i][j] = false
        end
    end
    for i = -row,row do
        for j = -col,col do
            local succ = false
            local temp = 0
            while(not succ) do
                temp=math.random(1,6)
                LinkBoard[i][j] = listanimals[temp]
                canremove = Logic:JudgeElimation(i,j,LinkBoard[i][j])
                if(not canremove) then
                    succ = true
                end
            end
            ModelIDArr[i][j] = Addmodel(listanimals[temp],i,0.05,j,nil)
        end
    end

    
end

function Init:StartInterface()
    AddLetters("LetterS",4,5,0,nil)
    AddLetters("LetterT",2,5,0,nil)
    AddLetters("LetterA",0,5,0,nil)
    AddLetters("LetterR",-2,5,0,nil)
    AddLetters("LetterT",-4,5,0,nil)
    AddLetters("LetterG",3,0,0,nil)
    AddLetters("LetterA",1,0,0,nil)
    AddLetters("LetterM",-1,0,0,nil)
    AddLetters("LetterE",-3,0,0,nil)
    
end


function Addmodel(name,px,py,pz,materialName)
    local modelID = addModel(name,px,py,pz)
    local modelColID = addCollider(modelID,1,0.5,0,0,0)
    if(materialName) then
        setModelMaterial(modelID,materialName)
    end
    animatedModels[modelID] = true
    --rotYVelModel[modelID] = 1
    local a = Animate:new(nil,modelID)
    AnimateInit(a,modelID)
    Anim[modelID] = a
    Anim[modelID]:squashY()
    return modelID
end

function AddLetters(name,px,py,pz,materialName)
    local modelID = addModel(name,px,py,pz)
    local modelColID = addCollider(modelID,1,0.5,0,0,0)
    if(materialName) then
        setModelMaterial(modelID,materialName)
    end
    StartModels[modelID] = name
    local Angle = math.random(0,45)*math.pi/180
    StartModelAngles[modelID] = Angle
    rotateModel(modelID,Angle, 1, 0, 0)
    rotYVelModel[modelID] = 1
    return modelID
end

function AnimateInit(a,ID)
    a.modelID = ID 
    rx,ry,rz = getModelScale(a.modelID)
    ps,py,pz = getModelPos(a.modelID)
    a.sizeY = ry
    a.posx = px
    a.posY = py
    a.posz = pz
    a.velY = 2
    a.stretch = true
    a.Isthrow = false
    a.MAX_SIZE = 1.5
    a.MIN_SIZE = 0.8
    a.vel = vec3(0,0,0)
    a.target = vec3(0,0,0)
    a.Isjumping = true
    a.Isstretch = true
end
return Init