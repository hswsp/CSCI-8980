Objectid = {}
NumberObjID = {}
Numbersize = {}
Numberenlarg = {}
ObjdeltPox = {}
Numberid = {}
Numberid["0"] = "Number0"
Numberid["1"] = "Number1"
Numberid["2"] = "Number2"
Numberid["3"] = "Number3"
Numberid["4"] = "Number4"
Numberid["5"] = "Number5"
Numberid["6"] = "Number6"
Numberid["7"] = "Number7"
Numberid["8"] = "Number8"
Numberid["9"] = "Number9"

require "Game/GameLogic"
local End = {}

function End:EndInterface()
    math.randomseed(os.time())
    scorestring = tostring(score)
    local i = 1
    local len = string.len(scorestring)  
    local startx = 8
    AddEndLetters("LetterS",startx + 4,1,0,nil)
    AddEndLetters("LetterC",startx + 2,1,0,nil)
    AddEndLetters("LetterO",0,1,0,nil)
    AddEndLetters("LetterR",startx -2,1,0,nil)
    AddEndLetters("LetterE",startx -4,1,0,nil)
 
    while(i<= len)  do
        AddEndNumbers(Numberid[string.sub(scorestring, i, i)],startx - i,3,0,nil)
        i = i + 1
    end    
end

function AddEndLetters(name,px,py,pz,materialName)
    local modelID = addModel(name,px,py,pz)
    if(materialName) then
        setModelMaterial(modelID,materialName)
    end
    Objectid[modelID] = name
    ObjdeltPox[modelID] = 0
    local Angle = math.random(0,45)*math.pi/180
    rotateModel(modelID,Angle, 0, 0, 1)
    return modelID
end

function AddEndNumbers(name,px,py,pz,materialName)
    local modelID = addModel(name,px,py,pz)
    if(materialName) then
        setModelMaterial(modelID,materialName)
    end
    NumberObjID[modelID] = name
    ObjdeltPox[modelID] = 0
    Numbersize[modelID] = 1
    Numberenlarg[modelID] = true
    return modelID
end


return End