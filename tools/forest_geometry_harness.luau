-- Offline authoring harness: actual generator code, rigid CFrames, conservative
-- oriented boxes. It does not emulate Roblox rendering or humanoid physics.
local vm = {}
local function v(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vm) end
vm.__add=function(a,b) return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vm.__sub=function(a,b) return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vm.__unm=function(a) return v(-a.X,-a.Y,-a.Z) end
vm.__mul=function(a,b) if type(a)=="number" then a,b=b,a end return v(a.X*b,a.Y*b,a.Z*b) end
vm.__div=function(a,b) return a*(1/b) end
local function dot(a,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end
local function cross(a,b) return v(a.Y*b.Z-a.Z*b.Y,a.Z*b.X-a.X*b.Z,a.X*b.Y-a.Y*b.X) end
vm.__index=function(a,k)
	if k=="Dot" then return dot elseif k=="Cross" then return cross
	elseif k=="Lerp" then return function(_,b,t) return a+(b-a)*t end
	elseif k=="Magnitude" then return math.sqrt(dot(a,a)) elseif k=="Unit" then return a/a.Magnitude end
end
local cm={}
local function frame(p,x,y,z) return setmetatable({Position=p or v(),RightVector=x or v(1,0,0),UpVector=y or v(0,1,0),ZVector=z or v(0,0,1)},cm) end
local function rotate(a,b) return a.RightVector*b.X+a.UpVector*b.Y+a.ZVector*b.Z end
local function unrotate(a,b) return v(dot(a.RightVector,b),dot(a.UpVector,b),dot(a.ZVector,b)) end
cm.__mul=function(a,b) return frame(a.Position+rotate(a,b.Position),rotate(a,b.RightVector),rotate(a,b.UpVector),rotate(a,b.ZVector)) end
cm.__add=function(a,b) return frame(a.Position+b,a.RightVector,a.UpVector,a.ZVector) end
cm.__index=function(a,k)
	if k=="LookVector" then return -a.ZVector elseif k=="Rotation" then return frame(v(),a.RightVector,a.UpVector,a.ZVector)
	elseif k=="PointToWorldSpace" then return function(_,p) return a.Position+rotate(a,p) end
	elseif k=="PointToObjectSpace" then return function(_,p) return unrotate(a,p-a.Position) end
	elseif k=="ToObjectSpace" then return function(_,b) return frame(unrotate(a,b.Position-a.Position),unrotate(a,b.RightVector),unrotate(a,b.UpVector),unrotate(a,b.ZVector)) end end
end
local CFrame={new=function(x,y,z) return frame(type(x)=="table" and x or v(x,y,z)) end}
CFrame.identity=frame()
CFrame.fromMatrix=frame
CFrame.Angles=function(x,y,z)
	local cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
	return frame(v(),v(1,0,0),v(0,cx,sx),v(0,-sx,cx))*frame(v(),v(cy,0,-sy),v(0,1,0),v(sy,0,cy))*frame(v(),v(cz,sz,0),v(-sz,cz,0),v(0,0,1))
end
CFrame.lookAt=function(p,target)
	local z=(p-target).Unit
	local up=math.abs(z.Y)>0.999 and v(0,0,1) or v(0,1,0)
	local x=cross(up,z).Unit
	return frame(p,x,cross(z,x),z)
end
local colorMeta={__index={}}
colorMeta.__index.Lerp=function(a,b,t) return setmetatable({R=a.R+(b.R-a.R)*t,G=a.G+(b.G-a.G)*t,B=a.B+(b.B-a.B)*t},colorMeta) end
local Color3={fromRGB=function(r,g,b) return setmetatable({R=r/255,G=g/255,B=b/255},colorMeta) end}
local Enum=setmetatable({}, {__index=function(a,k) local g=setmetatable({}, {__index=function(b,n) rawset(b,n,n); return n end}); rawset(a,k,g); return g end})
local methods,im={},{}
local serial=0
local function instance(class)
	serial+=1
	return setmetatable({_id=serial,_props={Name=class,ClassName=class,CFrame=frame(),Size=v(1,1,1),Transparency=0,CanCollide=true},_children={},_attributes={}},im)
end
im.__index=function(a,k)
	if methods[k] then return methods[k] end
	if k=="Position" then return a._props.CFrame.Position end
	if a._props[k]~=nil then return a._props[k] end
	for _, child in a._children do if child.Name==k then return child end end
end
im.__newindex=function(a,k,b)
	if k=="Parent" then
		local old=a._props.Parent
		if old then table.remove(old._children,table.find(old._children,a)) end
		if b then table.insert(b._children,a) end
	end
	a._props[k]=b
end
function methods:GetChildren() return table.clone(self._children) end
function methods:GetDescendants() local out={} for _,c in self._children do table.insert(out,c); for _,d in c:GetDescendants() do table.insert(out,d) end end return out end
function methods:IsA(c) return self.ClassName==c or c=="Instance" or c=="BasePart" and (self.ClassName=="Part" or self.ClassName=="WedgePart") end
function methods:FindFirstChild(n) for _,c in self._children do if c.Name==n then return c end end end
function methods:FindFirstChildOfClass(n) for _,c in self._children do if c.ClassName==n then return c end end end
function methods:IsDescendantOf(p) local a=self.Parent while a do if a==p then return true end a=a.Parent end return false end
function methods:GetFullName() return self.Parent and self.Parent:GetFullName().."."..self.Name or self.Name end
function methods:SetAttribute(n,b) self._attributes[n]=b end
function methods:GetAttribute(n) return self._attributes[n] end
function methods:GetAttributes() return table.clone(self._attributes) end
function methods:Destroy() self.Parent=nil end
function methods:GetPivot() return self.PrimaryPart and self.PrimaryPart.CFrame or frame() end
local function halfBounds(cf,size)
	local x,y,z=cf.RightVector,cf.UpVector,cf.ZVector
	return v(math.abs(x.X)*size.X+math.abs(y.X)*size.Y+math.abs(z.X)*size.Z,
		math.abs(x.Y)*size.X+math.abs(y.Y)*size.Y+math.abs(z.Y)*size.Z,
		math.abs(x.Z)*size.X+math.abs(y.Z)*size.Y+math.abs(z.Z)*size.Z)/2
end
function methods:GetBoundingBox()
	local lo,hi=v(math.huge,math.huge,math.huge),v(-math.huge,-math.huge,-math.huge)
	for _,p in self:GetDescendants() do if p:IsA("BasePart") then
		local h=halfBounds(p.CFrame,p.Size); local a,b=p.Position-h,p.Position+h
		lo=v(math.min(lo.X,a.X),math.min(lo.Y,a.Y),math.min(lo.Z,a.Z)); hi=v(math.max(hi.X,b.X),math.max(hi.Y,b.Y),math.max(hi.Z,b.Z))
	end end
	return frame((lo+hi)/2),hi-lo
end
function methods:Clone()
	local lookup={}
	local function copy(o)
		local b=instance(o.ClassName); lookup[o]=b
		for k,value in o._props do if k~="Parent" then b[k]=value end end
		b._attributes=table.clone(o._attributes)
		for _,c in o._children do copy(c).Parent=b end
		return b
	end
	local result=copy(self)
	for _,obj in lookup do for k,value in obj._props do if lookup[value] then obj._props[k]=lookup[value] end end end
	return result
end
local services={}
local workspace=instance("Workspace")
services.Workspace=workspace
services.RunService={IsRunning=function() return false end}
services.Selection={Set=function() end}
local game={GetService=function(_,name) if not services[name] then services[name]=instance(name) end return services[name] end}
local function intersects(ac,as,bc,bs)
	local delta=bc.Position-ac.Position
	local ah,bh=halfBounds(ac,as),halfBounds(bc,bs)
	if math.abs(delta.X)>ah.X+bh.X or math.abs(delta.Y)>ah.Y+bh.Y or math.abs(delta.Z)>ah.Z+bh.Z then return false end
	local aa,ba={ac.RightVector,ac.UpVector,ac.ZVector},{bc.RightVector,bc.UpVector,bc.ZVector}
	local av,bv={as.X/2,as.Y/2,as.Z/2},{bs.X/2,bs.Y/2,bs.Z/2}
	local axes={aa[1],aa[2],aa[3],ba[1],ba[2],ba[3]}
	for _,a in aa do for _,b in ba do table.insert(axes,cross(a,b)) end end
	for _,axis in axes do
		local ra,rb=0,0
		for i=1,3 do ra+=av[i]*math.abs(dot(aa[i],axis)); rb+=bv[i]*math.abs(dot(ba[i],axis)) end
		if math.abs(dot(delta,axis))>ra+rb+0.00001 then return false end
	end
	return true
end
function workspace:GetPartBoundsInBox(cf,size,params)
	local out={}
	for _,parent in params.FilterDescendantsInstances do for _,p in parent:GetDescendants() do
		if p:IsA("BasePart") and p.CanQuery and intersects(cf,size,p.CFrame,p.Size) then table.insert(out,p) end
	end end
	return out
end
function workspace:Raycast(origin,direction,params)
	assert(direction.X==0 and direction.Z==0 and direction.Y<0,"Harness supports vertical floor rays only")
	local best
	for _,parent in params.FilterDescendantsInstances do for _,p in parent:GetDescendants() do if p:IsA("BasePart") and p.CanQuery then
		local h=halfBounds(p.CFrame,p.Size)
		local y=p.Position.Y+h.Y
		if math.abs(origin.X-p.Position.X)<=h.X and math.abs(origin.Z-p.Position.Z)<=h.Z and y<=origin.Y and y>=origin.Y+direction.Y and (not best or y>best.Position.Y) then
			best={Position=v(origin.X,y,origin.Z),Normal=v(0,1,0),Instance=p}
		end
	end end end
	return best
end
local Random={new=function(seed)
	local state=seed
	local r={NextNumber=function(_,low,high) state=(state*48271)%2147483647; local n=state/2147483647; return (low or 0)+n*((high or 1)-(low or 0)) end}
	r.NextInteger=function(self,low,high) return math.min(high,math.floor(self:NextNumber(low,high+1))) end
	return r
end}
local function sequence(...) return {...} end
local env=setmetatable({game=game,workspace=workspace,Instance={new=instance},Vector3={new=v,zero=v(),one=v(1,1,1)},
	CFrame=CFrame,Color3=Color3,Enum=Enum,Random=Random,Vector2={new=function(x,y) return {X=x,Y=y} end},
	ColorSequence={new=sequence},NumberSequence={new=sequence},NumberSequenceKeypoint={new=sequence},NumberRange={new=sequence},
	RaycastParams={new=function() return {} end},OverlapParams={new=function() return {} end},warn=print,
}, {__index=getfenv()})
local function run(source,name)
	local fn=assert(loadstring(source,name)); setfenv(fn,env); fn()
end
-- GENERATORS
-- Export actual authored geometry for offline diagnostics, not a Studio screenshot.
for _,p in workspace.Maps.Forest:GetDescendants() do
	if p:IsA("BasePart") then
		local h=halfBounds(p.CFrame,p.Size)
		local cf=p.CFrame
		print(string.format("GEOM|%s|%s|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f|%s|%d|%s|%s|%.4f|%.4f|%.4f|%.6f|%.6f|%.6f|%.6f|%.6f|%.6f|%.6f|%.6f|%.6f|%.4f|%.4f|%.4f",
			p.Parent.Name,p.Name,p.Position.X,p.Position.Y,p.Position.Z,h.X,h.Y,h.Z,tostring(p.CanCollide),p.Parent._id,p.ClassName,tostring(p.Shape),p.Color.R,p.Color.G,p.Color.B,
			cf.RightVector.X,cf.RightVector.Y,cf.RightVector.Z,cf.UpVector.X,cf.UpVector.Y,cf.UpVector.Z,cf.ZVector.X,cf.ZVector.Y,cf.ZVector.Z,p.Size.X,p.Size.Y,p.Size.Z))
	end
end
