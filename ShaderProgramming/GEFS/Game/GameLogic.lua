Animate = require "Game/Animation"
LinkBoard = {} -- model array
ModelIDArr = {} --record modelID
state = {} -- false for not remove, true for should be remove
listanimals={"Cow","Cube2","Frog","Sheep","Zebra","Whale"}
Anim ={}
local GameLogic  = {}
row = 5
col = 5
score=0

function GameLogic:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function GameLogic:remove(x,y,target)
    local cntx = 0
    local cnty = 0
    if(JudgeHorizontalElimation(x,y,target))then
        cnty = removeHorizontalBFS(x,y,target)
    end
    state[x][y] = false
    if(JudgeVerticalElimation(x,y,target)) then
        cntx = removeVerticalBFS(x,y,target)
    elseif cnty>=3 then
        state[x][y] = true
    end
    if cntx <3 and cnty<3 then 
        return false
    else
        return true
    end
    -- return cntx,cnty
end

function GameLogic:adjustment()

    for j = -col,col do
        for i = -row ,row do
            print("j,i:",j,i,LinkBoard[i][j],state[i][j])
        end
    end
    
    local HasElimination = true
    while(HasElimination) do
        local startx = {}  -- record the start x of the changed model
        local starti = {}  -- record the start x of the new model

        for j = -col, col do
            local temp = {}
            local Mtmp = {}
            local k = 0
            startx[j] = nil
            local endx = nil
            for i = -row,row do
                if(not state[i][j]) then
                    temp[k] = LinkBoard[i][j]
                    Mtmp[k] = ModelIDArr[i][j]
                    k = k + 1
                    if startx[j] ~= nil and endx==nil then
                        endx = i
                    end
                    
                    if startx[j] ~= nil and endx~=nil then
                        -- begin translate
                        local dx = endx - startx[j]
                        translateModel(ModelIDArr[i][j],-dx,0,0)
                    end
                else -- remove the model
                    HasElimination  = true
                    deleteModel(ModelIDArr[i][j])
                    score=score+1
                    
                    if startx[j] == nil then
                        startx[j] = i
                    end
                end
            end
            local r = -row
            for i = 0,k-1 do
                LinkBoard[r][j] =  temp[i]
                ModelIDArr[r][j] = Mtmp[i]
                state[r][j] = false
                r = r + 1
            end
            math.randomseed(os.time())
            starti[j] = r
            while(r<=row) do
                state[r][j] = true
                LinkBoard[r][j] =  "nil"
                ModelIDArr[r][j] = nil
                r = r + 1
            end
        end

        for j = -col, col do
            r = starti[j]
            while(r<=row) do
                AddOneAnimal(r,j)
                r = r + 1
            end
        end

        -- for j = -col,col do
        --     for i = -row ,row do
        --         print("j,i:",j,i,LinkBoard[i][j],state[i][j])
        --     end
        -- end

        HasElimination = false
        for j = -col, col do
            while true do  --work as continue
                print(startx[j])
                local i = startx[j]
                if i==nil then break end
                while(i<=row) do
                    local Elim = Logic:remove(i,j,LinkBoard[i][j])
                    if(Elim) then
                        -- print("remove new one")
                        HasElimination = true
                        -- for j = -col,col do
                        --     for i = -row ,row do
                        --         print("j,i:",j,i,LinkBoard[i][j],state[i][j])
                        --     end
                        -- end
                    end
                    i = i + 1
                end
                break
            end
        end
    end
end

function GameLogic:JudgeElimation(x,y,target)
    if (JudgeVerticalElimation(x,y,target) or JudgeHorizontalElimation(x,y,target)) then
        return true
    else
        return false
    end
end

function GameLogic:resetState()
    local cnt = 0
    for i = -row ,row do
        for j = -col,col do
            state[i][j] = false
        end
    end
end


function Isvalid(x, y)
    if (x < -row or x > row or y < -col or y > col or state[x][y]) then
        return false;
    end
    return true;
end
function JudgeVerticalElimation(x,y,target)
    local cntx = 0
    local cntxmax = 0
    for i = x-2,x+2 do
        if Isvalid(i, y)  and LinkBoard[i][y] == target then
            cntx = cntx + 1
        else
            cntxmax = math.max(cntxmax,cntx)
            cntx = 0
        end
        -- print("cntxmax:",LinkBoard[x][y],target,cntxmax)
    end
    cntxmax = math.max(cntxmax,cntx)
    if cntxmax >=3 then
        return true
    else
        return false
    end
end
function JudgeHorizontalElimation(x,y,target)
    local cnty = 0
    local cntymax = 0
    for j = y-2,y+2 do
        if Isvalid(x, j) and LinkBoard[x][j] == target then      
            cnty = cnty + 1
        else
            cntymax = math.max(cntymax,cnty)
            cnty = 0
        end
    end
    cntymax = math.max(cntymax,cnty)
    if cntymax >=3 then
        return true
    else
        return false
    end
end
function removeHorizontalBFS(x,y,target)
    if (not Isvalid(x, y)) then return 0 end
    if (LinkBoard[x][y] ~= target)then return 0 end
    state[x][y] = true
    local cnt = 1
    cnt = cnt + removeHorizontalBFS(x, y + 1, target)
    cnt = cnt + removeHorizontalBFS(x, y - 1, target)
    return cnt
end
function removeVerticalBFS(x,y,target)
    if (not Isvalid(x, y)) then return 0 end
    if (LinkBoard[x][y] ~= target)then return 0 end
    state[x][y] = true
    local cnt = 1
    cnt = cnt + removeVerticalBFS(x + 1, y, target)
    cnt = cnt + removeVerticalBFS(x - 1, y, target)
    return cnt
end

function AddOneAnimal(i,j)
    local succ = false
    local temp = 0
    while(not succ) do
        temp=math.random(1,6)
        LinkBoard[i][j] = listanimals[temp]
        state[i][j] = false
        canremove = GameLogic:JudgeElimation(i,j,LinkBoard[i][j])
        if(not canremove) then
            succ = true
        end
    end
    ModelIDArr[i][j] = Addmodel(listanimals[temp],i,0.05,j,nil)
    
end

function Addmodel(name,px,py,pz,materialName)
    local modelID = addModel(name,px,py,pz)
    local modelColID = addCollider(modelID,1,0.5,0,0,0)
    if(materialName) then
        setModelMaterial(modelID,materialName)
    end
    animatedModels[modelID] = true
    local a = Animate:new(nil,modelID)
    AnimateInit(a,modelID)
    Anim[modelID] = a
    Anim[modelID]:squashY()
    return modelID
end

return GameLogic