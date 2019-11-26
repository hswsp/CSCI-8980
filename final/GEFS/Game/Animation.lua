require "CommonLibs/vec3"
g = vec3(0,-9.8,0)

local Animate ={
    modelID ,
    MAX_SIZE,
    MIN_SIZE,
    sizeY ,
    posX,posY,posZ,
    velY ,
    vel,
    stretch,
    Isstretch,
    Isthrow,
    Isjumping,
    target
}

function Dist(pxA,pyA,pzA,pxB,pyB,pzB)
    deltX = pxB - pxA
    deltY = pyB - pyA
    deltZ = pzB - pzA
    return math.sqrt(deltX*deltX +deltY*deltY +deltZ*deltZ)
end


function Animate:new(o,ID)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.modelID = ID or 0
    rx,ry,rz = getModelScale(self.modelID)
    ps,py,pz = getModelPos(self.modelID)
    self.sizeY = ry
    self.posx = px
    self.posY = py
    self.posz = pz
    self.velY = 1
    self.stretch = true
    self.MAX_SIZE = 1.5
    self.MIN_SIZE = 0.5
    return o
end

function Animate:jump()
    -- dt = dt*1/targetFrameRate*2
    local dt =  1e-2
    vel = self.velY
    ps,py,pz = getModelPos(self.modelID)
    --collision
    if(py<=self.posY and self.velY <= 0) then
        -- if(math.abs(self.velY)<0.1) then
        --     self.Isjumping =false
        -- end
        self.velY = - 0.0*vel
        self.stretch = false
        self.Isjumping =false
        translateModel(self.modelID,0,self.posY - py,0)
    else
        self.velY = vel + g.y*dt
        translateModel(self.modelID,0,vel*dt + 0.5*g.y*dt*dt,0)
    end
    
   
end
function Animate:squashY()
    scaleModel(self.modelID,1,0.5,1) 
end

function Animate:bounce()
    local dt = 1e-2
    vel = 5
    size = 1
    rx,ry,rz = getModelScale(self.modelID)
    if(self.MAX_SIZE>1  or self.MIN_SIZE<1) then
        if self.stretch then
            if ry  <= self.MAX_SIZE * self.sizeY then
                size = size + vel*dt
            else
                -- self.stretch = false
                self.MAX_SIZE = 1   --self.MAX_SIZE/1.8
            end
        else 
            if ry>= self.MIN_SIZE*self.sizeY  then
                size = size - vel*dt
            else
                self.stretch = true
                self.MIN_SIZE =  1 --self.MIN_SIZE*1.8
            end
        end
        scaleModel(self.modelID,1,size,1) 
    elseif(math.abs(ry -self.sizeY)> 0.01 ) then
        if ry  <= self.sizeY then size = size + vel*dt end
        -- if self.stretch then
        --     if ry  <= self.MAX_SIZE * self.sizeY then
        --         size = size + vel*dt
        --     else
        --         self.stretch = false
        --         self.MAX_SIZE = self.MAX_SIZE/1.8
        --     end
        -- else 
        --         if ry>= self.MIN_SIZE*self.sizeY  then
        --             size = size - vel*dt
        --         else
        --             self.stretch = true
        --             self.MIN_SIZE =  self.MIN_SIZE*1.8
        --         end
        --     end
            scaleModel(self.modelID,1,size,1) 
    else
        scaleModel(self.modelID,1,self.sizeY/ry,1) 
        self.Isstretch = false
    end
end

function Animate:InitThrow(TargetmodelID)
    --A to B
    if(not self.Isjumping) then
        orgxA,orgyA,orgzA = getModelPos(self.modelID)
        orgxB,orgyB,orgzB = getModelPos(TargetmodelID)
        self.target = vec3(orgxB,orgyB,orgzB) 
        deltX = orgxB - orgxA
        deltY = orgyB - orgyA
        deltZ = orgzB - orgzA
        Reach = math.sqrt(deltX*deltX +deltY*deltY +deltZ*deltZ)
        theta = math.rad(45)
        v0 = math.sqrt(Reach*math.abs(g.y)/math.sin(2*theta))
        dir = vec3(deltX,deltY,deltZ)
        dir = vec3.normalize(dir)
        -- 45 degree
        up = vec3(0,1,0)
        dir = dir + up
        dir = vec3.normalize(dir)
        self.vel = vec3.scale(dir,v0)
        self.Isthrow = true
    end
end

function Animate:computeThrow(TargetmodelID)
    dt = 1e-2 --dt*1/targetFrameRate*2
    newxA,newyA,newzA = getModelPos(self.modelID)
    if(Dist(self.target.x,self.target.y,self.target.z,newxA,newyA,newzA)>0.01 and self.target.y>=0) then
        vtemp = vec3.clone(self.vel)
        gtemp = vec3.clone(g)
        delt = vec3.scale(self.vel,dt)+vec3.scale(gtemp,dt*dt*0.5)
        gtemp = vec3.clone(g)
        self.vel = vtemp+vec3.scale(gtemp,dt)
        translateModel(self.modelID,delt.x,delt.y,delt.z)
    else
        translateModel(self.modelID,self.target.x -newxA ,self.target.y -newyA ,self.target.z -newzA )
        self.Isthrow = false
    end
end

function Animate:disappear()
    setModelMaterial(self.modelID,"Warm Light")
    Animate:bounce()
end


setmetatable(Animate, Animate)
return Animate

