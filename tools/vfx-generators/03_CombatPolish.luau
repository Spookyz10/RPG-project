-- Edit Mode installer. Curated particle layers reuse the user's ServerStorage.VFX library.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local RS=game:GetService("ReplicatedStorage")
local SS=game:GetService("ServerStorage")
local source=assert(SS:FindFirstChild("VFX"),"ServerStorage.VFX is required")
local old=assert(RS.Resources:FindFirstChild("CombatVFX"),"Install base combat templates first")
local library=Instance.new("Folder");library.Name="CombatVFX"
local groups={}
for _,name in {"Attacks","Skills","Statuses","Impacts"} do
	local f=Instance.new("Folder");f.Name=name;f.Parent=library;groups[name]=f
end
local textures={Slash="15124806555",Wind="15380148552",Ring="1266170131",Smoke="9171262291",Chip="6760190948",Flash="9710916533",Spark="15316530495",Glow="9589703753",Spore="16718731802",Rune="9572518235",Crack="11396737930"}
local originals={}
for _,e in source:GetDescendants() do
	if e:IsA("ParticleEmitter") then
		local id=string.match(e.Texture,"%d+")
		if id and not originals[id] then originals[id]=e end
	end
end
local function seq(...)
	local points={...};local keys={}
	for _,p in points do table.insert(keys,NumberSequenceKeypoint.new(p[1],p[2],p[3] or 0)) end
	return NumberSequence.new(keys)
end
local C={Leaf=Color3.fromRGB(150,218,86),Mint=Color3.fromRGB(132,255,202),Gold=Color3.fromRGB(255,196,102),Ice=Color3.fromRGB(174,228,255),Bark=Color3.fromRGB(127,95,60),Dust=Color3.fromRGB(170,150,117),Violet=Color3.fromRGB(191,146,255),White=Color3.fromRGB(255,242,217)}
local function model(group,name,duration,diameter,keepGeometry)
	local m=Instance.new("Model");m.Name=name;m:SetAttribute("Duration",duration);m:SetAttribute("Version",3)
	m:SetAttribute("Footprint",diameter);m:SetAttribute("SourceLibrary","ServerStorage.VFX")
	local root=Instance.new("Part");root.Name="VFXOrigin";root.Size=Vector3.one
	root.Transparency=1;root.Anchored=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.CastShadow=false
	root.Parent=m;m.PrimaryPart=root
	if keepGeometry then
		local previous=old[group]:FindFirstChild(name)
		if previous then
			local copy=previous:Clone();copy:PivotTo(CFrame.identity)
			for _,v in copy:GetDescendants() do
				if v:IsA("BasePart") and v.Transparency<1 and (v:GetAttribute("Structural") or not v:GetAttribute("VFXMotion")) then
					local part=v:Clone();part:ClearAllChildren();part:SetAttribute("Structural",true)
					part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.CastShadow=false
					if part.Material==Enum.Material.Neon then part.Transparency=math.max(part.Transparency,0.25) end
					part.Parent=m
				end
			end
			copy:Destroy()
		end
	end
	m.Parent=groups[group]
	return m,root
end
local function at(root,name,pos,rotation)
	local a=Instance.new("Attachment");a.Name=name;a.CFrame=CFrame.new(pos or Vector3.zero)*(rotation or CFrame.identity);a.Parent=root;return a
end
local function particle(parent,name,kind,color,size,count,life,properties)
	local id=textures[kind];local original=originals[id]
	local e=original and original:Clone() or Instance.new("ParticleEmitter")
	e:ClearAllChildren();for key in e:GetAttributes() do e:SetAttribute(key,nil) end
	e.Name=name;e.Texture="rbxassetid://"..id;e.Enabled=false;e.Rate=0
	e.Lifetime=NumberRange.new(life*0.8,life);e.Speed=NumberRange.new(0.01)
	e.Acceleration=Vector3.zero;e.Drag=0;e.VelocityInheritance=0;e.LockedToPart=false
	e.EmissionDirection=Enum.NormalId.Top;e.SpreadAngle=Vector2.zero
	e.Orientation=Enum.ParticleOrientation.FacingCamera;e.Rotation=NumberRange.new(0,360);e.RotSpeed=NumberRange.new(-20,20)
	e.Color=ColorSequence.new(color,color:Lerp(C.Dust,0.15));e.LightInfluence=0;e.LightEmission=0.65
	e.Brightness=1.4;e.ZOffset=0;e.TimeScale=1
	e.Size=seq({0,size*0.3},{0.15,size},{1,size*1.15})
	e.Transparency=seq({0,0.2},{0.2,0.08},{0.65,0.45},{1,1})
	-- Preserve the source flipbook layout: several textures are animated atlases.
	if not original then e.FlipbookLayout=Enum.ParticleFlipbookLayout.None end
	for key,value in properties or {} do e[key]=value end
	e:SetAttribute("EmitCount",count);e:SetAttribute("EmitDelay",0);e:SetAttribute("EmitDuration",0)
	-- Black-backed energy textures must be additive. Alpha smoke uses a verified local texture.
	if kind=="Smoke" then
		e.Texture="rbxasset://textures/particles/smoke_main.dds"
		e.FlipbookLayout=Enum.ParticleFlipbookLayout.None
		e.LightEmission=0.15;e.LightInfluence=0.25
		e:SetAttribute("BlendMode","Alpha")
	elseif kind=="Chip" then
		e.Texture="rbxasset://textures/particles/sparkles_main.dds"
		e.FlipbookLayout=Enum.ParticleFlipbookLayout.None
		e.LightEmission=1;e.LightInfluence=0;e:SetAttribute("BlendMode","Additive")
	else
		e.LightEmission=1;e.LightInfluence=0;e:SetAttribute("BlendMode","Additive")
	end
	e:SetAttribute("SourceTexture",id);e.Parent=parent
	return e
end
local function ring(parent,color,diameter,life,delay)
	local e=particle(parent,"PressureRing","Ring",color,diameter,1,life,{
		Orientation=Enum.ParticleOrientation.VelocityPerpendicular,Rotation=NumberRange.new(0),RotSpeed=NumberRange.new(0),
		Size=seq({0,diameter*0.15},{0.45,diameter*0.85},{1,diameter}),
		Transparency=seq({0,0.25},{0.3,0.4},{1,1}),LightEmission=0.5,Brightness=1.2})
	e:SetAttribute("EmitDelay",delay or 0);return e
end
local function flash(parent,color,size)
	return particle(parent,"ContactFlash","Flash",color,size,1,0.12,{LightEmission=1,Brightness=2,Size=seq({0,size*0.3},{0.1,size},{1,0})})
end
local function dust(parent,diameter,count)
	local e=particle(parent,"GroundDust","Smoke",C.Dust,diameter*0.12,count or 16,0.65,{
		Speed=NumberRange.new(diameter*0.18,diameter*0.45),SpreadAngle=Vector2.new(85,85),Drag=9,
		LightEmission=0.04,LightInfluence=0.65,Brightness=1,Acceleration=Vector3.new(0,0.5,0),
		Transparency=seq({0,1},{0.08,0.38},{0.45,0.64},{1,1})})
	e:SetAttribute("WorldSpace",true);e:SetAttribute("EmitDelay",0.04);return e
end
local function motes(parent,color,diameter,count)
	return particle(parent,"Embers","Spark",color,math.clamp(diameter*0.07,0.22,1.2),count or 24,0.55,{
		Speed=NumberRange.new(diameter*0.25,diameter*0.7),SpreadAngle=Vector2.new(75,75),Drag=7,
		Acceleration=Vector3.new(0,-6,0),Orientation=Enum.ParticleOrientation.VelocityParallel,
		Size=seq({0,0},{0.12,math.clamp(diameter*0.07,0.22,1.2)},{1,0})})
end

-- Geometry uses authored local transforms; CombatVFX owns its lifetime and animation.
local function gfx(m,name,cf,size,color,material,motion,life,delay)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Material=material or Enum.Material.Neon;p.Transparency=0.08;p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p:SetAttribute("VFXMotion",motion or "Grow");p:SetAttribute("VFXLife",life or 0.45)
 p:SetAttribute("VFXDelay",delay or 0);p:SetAttribute("VFXGrowFrom",0.22)
 p.Parent=m;return p
end
local function arc(m,cf,radius,first,last,segments,color,width,life,delay,motion,spin)
 for i=1,segments do
  local a=first+(last-first)*(i-1)/segments
  local b=first+(last-first)*i/segments
  local v0=Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
  local v1=Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius)
  local mid=(v0+v1)*0.5
  local taper=math.abs(last-first)>=6.2 and 1 or (0.25+0.75*math.sin(math.pi*(i-0.5)/segments))
  local p=gfx(m,"EnergyArc",cf*CFrame.lookAt(mid,v1),Vector3.new(width*taper,width*0.5,(v1-v0).Magnitude*1.04),color,nil,motion or "Radial",life,delay)
  p:SetAttribute("VFXAngular",spin or Vector3.zero)
  if motion=="Orbit" or motion=="Grow" then p:SetAttribute("VFXGrowFrom",1) end
 end
end
local function light(root,color,radius)
 local l=Instance.new("PointLight");l.Name="ImpactLight";l.Color=color;l.Range=math.min(26,radius);l.Brightness=3
 l.Shadows=false;l.Enabled=false;l:SetAttribute("VFXLife",0.2);l.Parent=root
end
local function ray(root,name,from,to,color,width,life,delay)
 local a=at(root,name.."Start",from);local b=at(root,name.."End",to)
 local beam=Instance.new("Beam");beam.Name=name;beam.Attachment0=a;beam.Attachment1=b
 beam.Width0=width;beam.Width1=width*0.05;beam.FaceCamera=true;beam.Color=ColorSequence.new(C.White,color)
 beam.Transparency=NumberSequence.new(0.12);beam.LightEmission=1;beam.LightInfluence=0
 beam.Segments=1;beam.Enabled=false;beam:SetAttribute("PreviewDuration",life);beam:SetAttribute("EmitDelay",delay or 0);beam.Parent=root
end
local function comet(part,color,width,life)
 local a=at(part,"TrailTop",Vector3.new(0,width*0.5,0));local b=at(part,"TrailBottom",Vector3.new(0,-width*0.5,0))
 local t=Instance.new("Trail");t.Name="CometTail";t.Attachment0=a;t.Attachment1=b
 t.Color=ColorSequence.new(C.White,color);t.Transparency=seq({0,0.1},{0.4,0.35},{1,1})
 t.WidthScale=seq({0,1},{1,0});t.LightEmission=1;t.LightInfluence=0;t.Lifetime=0.18
 t.FaceCamera=true;t.MinLength=0.03;t.Enabled=false;t:SetAttribute("PreviewDuration",life);t.Parent=part
end
local function eruption(m,root,diameter,color,organic)
 local radius=diameter*0.42
 light(root,color,diameter)
 arc(m,CFrame.new(0,0.22,0),diameter*0.46,0,math.pi*2,20,color,math.clamp(diameter*0.016,0.13,0.45),0.48,0)
 for i=1,6 do
  local angle=i*math.pi/3
  local a=at(root,"DustFront"..i,Vector3.new(math.cos(angle)*diameter*0.28,0.18,math.sin(angle)*diameter*0.28))
  local plume=dust(a,diameter*0.45,4);plume:SetAttribute("EmitDelay",0.04+i*0.008)
 end
 local count=diameter>=20 and 10 or 7
 for i=1,count do
  local angle=i*math.pi*2/count+0.23
  local direction=Vector3.new(math.cos(angle),0,math.sin(angle))
  local size=math.clamp(diameter*0.07,0.45,2.1)
  local rock=gfx(m,organic and "BarkFragment" or "LiftedRock",CFrame.new(direction*radius+Vector3.new(0,size*0.3,0))*CFrame.Angles(i*0.4,angle,i*0.16),Vector3.new(size,size*0.65,size*1.1),organic and C.Bark or C.Dust,Enum.Material.Slate,"Shard",0.65,0.035)
  rock:SetAttribute("VFXVelocity",direction*diameter*0.1+Vector3.new(0,7+i%3,0))
  rock:SetAttribute("VFXAngular",Vector3.new(i%3,1.8,-1));rock:SetAttribute("VFXGravity",28)
  local core=gfx(m,"LuminousSplinter",CFrame.new(direction*radius*0.38+Vector3.new(0,0.6,0)),Vector3.new(size*0.22,size*1.5,size*0.22),color,nil,"Shard",0.48,0.02)
  core:SetAttribute("VFXVelocity",direction*diameter*0.25+Vector3.new(0,8,0));core:SetAttribute("VFXGravity",30)
  core:SetAttribute("VFXAngular",Vector3.new(1.5,angle,2))
  if i%2==0 then comet(core,color,size*0.4,0.4) end
  if not organic then
   local start=direction*diameter*0.07
   local finish=direction*diameter*0.34
   local fissure=gfx(m,"MoltenFissure",CFrame.lookAt((start+finish)/2+Vector3.new(0,0.12,0),finish+Vector3.new(0,0.12,0)),Vector3.new(size*0.13,0.04,(finish-start).Magnitude),color,nil,"Grow",0.55,0)
   fissure:SetAttribute("VFXGrowFrom",0.8)
   local branchStart=direction*diameter*0.23
   local branchEnd=branchStart+Vector3.new(-direction.Z,0,direction.X)*diameter*0.075+direction*diameter*0.065
   local branch=gfx(m,"FissureBranch",CFrame.lookAt((branchStart+branchEnd)/2+Vector3.new(0,0.13,0),branchEnd+Vector3.new(0,0.13,0)),Vector3.new(size*0.09,0.035,(branchEnd-branchStart).Magnitude),color,nil,"Grow",0.45,0.045)
   branch:SetAttribute("VFXGrowFrom",0.55)
  end
 end
 ray(root,"EruptionCore",Vector3.new(0,0.3,0),Vector3.new(0,math.min(9,diameter*0.36),0),color,math.min(3.5,diameter*0.17),0.26)
end

local function impact(group,name,diameter,color,duration,organic,keepGeometry)
	local m,r=model(group,name,duration or 1,diameter,keepGeometry)
	local floor=at(r,"GroundPlane",Vector3.new(0,0.16,0))
	ring(floor,color,diameter,0.48)
	ring(floor,color:Lerp(C.White,0.5),diameter*0.72,0.36,0.07)
	flash(at(r,"Contact",Vector3.new(0,0.7,0)),color,math.min(8,diameter*0.45))
	dust(floor,diameter,math.clamp(math.floor(diameter*0.6),7,18))
	motes(floor,color,diameter)
	local chips=particle(floor,"Debris","Chip",organic and C.Leaf or C.Bark,0.24,12,0.65,{
		Speed=NumberRange.new(6,math.min(20,diameter)),SpreadAngle=Vector2.new(65,65),Acceleration=Vector3.new(0,-38,0),
		LightEmission=0,LightInfluence=0.8,RotSpeed=NumberRange.new(-160,160),Size=seq({0,0.15},{0.2,0.28},{1,0})})
	chips:SetAttribute("EmitDelay",0.03)
	if organic then
		particle(floor,"VerdantBloom","Spore",color,diameter*0.7,1,0.5,{
			Orientation=Enum.ParticleOrientation.VelocityPerpendicular,LightEmission=0.3,
			Transparency=seq({0,0.55},{0.3,0.65},{1,1})})

	end
	eruption(m,r,diameter,color,organic)
	return m,r
end
local function slash(group,name,width,color,angle)
	local m,r=model(group,name,0.5,width)
	local a=at(r,"SlashPlane",Vector3.new(0,0.2,0),CFrame.Angles(math.rad(65),0,math.rad(angle or -25)))
	particle(a,"BladeArc","Slash",color,width,1,0.22,{
		Orientation=Enum.ParticleOrientation.VelocityPerpendicular,Rotation=NumberRange.new(0),RotSpeed=NumberRange.new(0),
		Size=seq({0,width*0.7},{0.15,width},{1,width*1.04}),LightEmission=0.9,
		Transparency=seq({0,0.05},{0.28,0.1},{1,1})})
	local echo=particle(a,"ArcAfterimage","Slash",color:Lerp(C.White,0.65),width*0.85,1,0.19,{
		Orientation=Enum.ParticleOrientation.VelocityPerpendicular,Rotation=NumberRange.new(12),RotSpeed=NumberRange.new(0),
		Transparency=seq({0,0.45},{0.4,0.65},{1,1})})
	echo:SetAttribute("EmitDelay",0.035)
	flash(a,C.White,math.min(3.5,width*0.42));motes(a,color,width,18)
 local plane=CFrame.new(0,0.2,0)*CFrame.Angles(math.rad(65),0,math.rad(angle or -25))
 arc(m,plane,width*0.46,-2.5,0.65,18,color,math.clamp(width*0.055,0.3,0.85),0.3,0,"Orbit",Vector3.new(0,3,0))
 arc(m,plane*CFrame.new(0,0.13,0),width*0.39,-2.2,0.3,12,C.White,math.clamp(width*0.013,0.08,0.24),0.22,0.025,"Orbit",Vector3.new(0,3,0))
 light(r,color,width*1.5)
	return m,r
end
for name,settings in {
	Bushling={4,C.Leaf},Wolf={7,C.Ice},Boar={5.5,C.Gold},["Dire Bear"]={19,C.Gold},
	Mosscap={7,C.Violet},["Thornback Stag"]={8,C.Leaf},["Hollow Sentinel"]={9,C.Mint},Elderbark={20,C.Mint},
} do slash("Attacks",name.."Melee",settings[1],settings[2]) end
slash("Attacks","Melee",6,C.White)
slash("Attacks","DoubleSwipe",20,C.Gold)
slash("Attacks","RootSweep",26,C.Mint,10)
for i=1,3 do slash("Skills","Basic"..i,6,C.White,({-32,32,-65})[i]) end
slash("Skills","Basic",6,C.White)
slash("Skills","Lure Jab",7,C.Leaf,-75)
impact("Attacks","Spikes",6,C.Leaf,1.3,true,true)
impact("Attacks","GroundSlam",32,C.Gold,1,false)
impact("Attacks","DireBearJumpImpact",22,C.Gold,1,false)
impact("Attacks","CavefallImpact",14,C.Gold,0.8,false)
impact("Attacks","HeartSlam",36,C.Mint,0.7,true)
impact("Attacks","SporeBloom",14,C.Violet,0.7,true)
impact("Attacks","SporeEcho",20,C.Violet,0.7,true)
impact("Attacks","ElderRoots",12,C.Mint,0.8,true,true)
impact("Skills","Ground Break",12,C.Gold,1.2,false)
impact("Impacts","Maul",7,C.Gold,0.7,false)
-- Long root lanes retain their authored silhouette; particles mark each section.
do
	local m,r=model("Attacks","SentinelRoots",0.65,28,true)
	for i=-2,2 do
		local a=at(r,"RootSegment"..i,Vector3.new(0,0.15,i*5))
		ring(a,C.Mint,8,0.42,math.abs(i)*0.025);motes(a,C.Leaf,5,5);dust(a,6,4)
	end
end
-- A clear warning remains readable under the red gameplay telegraph.
do
	local m,r=model("Attacks","SpikeWarning",2,6)
	local a=at(r,"Gather",Vector3.new(0,0.12,0))
	local e=ring(a,C.Leaf,5.8,0.7);e.Rate=2;e:SetAttribute("EmitDuration",1.6)
	local e2=motes(a,C.Leaf,3,5);e2.Rate=6;e2.Speed=NumberRange.new(0.5,1);e2.Acceleration=Vector3.new(0,1,0);e2:SetAttribute("EmitDuration",1.65)
end
-- Rotating wind textures, bounded to the damage footprint.
for _,spec in {{"Attacks","TailSpin",20,C.Ice,2},{"Skills","Cyclone",10,C.Ice,1.2}} do
	local m,r=model(spec[1],spec[2],spec[5],spec[3])
	for i=1,3 do
		local a=at(r,"WindBand"..i,Vector3.new(0,(i-2)*0.7,0))
		local e=particle(a,"Spiral","Wind",spec[4],spec[3]*(0.7+i*0.1),1,0.32,{
			Orientation=Enum.ParticleOrientation.VelocityPerpendicular,Rate=6,RotSpeed=NumberRange.new(160,220),
			Transparency=seq({0,0.25},{0.4,0.38},{1,1})})
		e:SetAttribute("EmitDelay",(i-1)*0.05);e:SetAttribute("EmitDuration",spec[5]-0.42)
	end
	local sparks=motes(at(r,"Wake"),spec[4],spec[3]*0.5,8);sparks.Rate=12;sparks:SetAttribute("EmitDuration",spec[5]-0.55)
end
for _,spec in {{"Rush",C.Gold,7,0.95},{"AntlerRush",C.Mint,8,1.1}} do
	local m,r=model("Attacks",spec[1],spec[4],spec[3])
	for side=-1,1,2 do
		local a=at(r,"Wake"..side,Vector3.new(side*spec[3]*0.3,-1.5,1.5))
		local e=dust(a,spec[3],4);e.Rate=18;e:SetAttribute("EmitDuration",spec[4]-0.25)
		local s=motes(a,spec[2],4,3);s.Rate=10;s:SetAttribute("EmitDuration",spec[4]-0.35);s:SetAttribute("WorldSpace",true)
	end
	local a=at(r,"BowWave",Vector3.new(0,0,-2.5),CFrame.Angles(math.pi/2,0,0))
	local e=ring(a,spec[2],spec[3],0.26);e.Rate=5;e:SetAttribute("EmitDuration",spec[4]-0.3)
end
do
	local m,r=model("Attacks","Roar",1.1,48)
	local a=at(r,"Pressure",Vector3.new(0,0.3,0))
	for i=0,2 do ring(a,i==0 and C.White or C.Gold,48-i*5,0.65,i*0.12) end
	dust(a,32,14);flash(at(r,"Core",Vector3.new(0,3,0)),C.Gold,6)
end
for _,spec in {{"Skills","Blessing",C.Gold,1.2},{"Impacts","Regrowth",C.Mint,1.3}} do
	local m,r=model(spec[1],spec[2],spec[4],6)
	local a=at(r,"Sigil",Vector3.new(0,-2.5,0))
	particle(a,"HealingSigil","Rune",spec[3],5.5,1,0.9,{Orientation=Enum.ParticleOrientation.VelocityPerpendicular,RotSpeed=NumberRange.new(25)})
	ring(a,spec[3],6,0.6)
	local e=motes(a,spec[3],5,18);e.Speed=NumberRange.new(2,4);e.Acceleration=Vector3.new(0,4,0);e.SpreadAngle=Vector2.new(25,25);e.Lifetime=NumberRange.new(0.65,0.9)
	particle(at(r,"Warmth"),"SoftGlow","Glow",spec[3],3,1,0.75,{Transparency=seq({0,1},{0.15,0.8},{1,1}),LightEmission=0.4})
end
for _,spec in {{"Poison",C.Leaf},{"Venom",C.Leaf},{"Lure Jab",C.Leaf},{"Fury",C.Gold},{"Safeguard",C.Ice}} do
	local m,r=model("Statuses",spec[1],5,5)
	local a=at(r,"Aura",Vector3.new(0,0.5,0))
	local e=motes(a,spec[2],2.5,5);e.Rate=5;e.Speed=NumberRange.new(0.4,1.3);e.Acceleration=Vector3.new(0,0.8,0)
	e.Size=seq({0,0},{0.2,0.15},{1,0});e.Lifetime=NumberRange.new(0.7,1.2)
	if spec[1]=="Poison" then
		particle(a,"ToxicVapor","Smoke",C.Leaf,1.25,3,1.1,{Rate=3,Speed=NumberRange.new(0.5,1),LightEmission=0.05,
			Transparency=seq({0,1},{0.25,0.78},{1,1}),Acceleration=Vector3.new(0,0.4,0)})
	else
		local floor=at(r,"Seal",Vector3.new(0,-1.1,0))
		local seal=particle(floor,"StatusSeal","Rune",spec[2],spec[1]=="Safeguard" and 5 or 3.6,1,1.2,{
			Rate=0.85,Orientation=Enum.ParticleOrientation.VelocityPerpendicular,RotSpeed=NumberRange.new(18),
			Transparency=seq({0,1},{0.2,0.55},{0.7,0.65},{1,1})})
		if spec[1]=="Safeguard" then
			local shield=Instance.new("Part");shield.Name="Shield";shield.Shape=Enum.PartType.Ball;shield.Size=Vector3.new(5.5,6.5,5.5)
			shield.Material=Enum.Material.ForceField;shield.Color=spec[2];shield.Transparency=0.78
			shield.Anchored=true;shield.CanCollide=false;shield.CanTouch=false;shield.CanQuery=false;shield.CastShadow=false
			shield.CFrame=CFrame.new(0,1.1,0);shield.Parent=m
		end
	end
end

-- Distinct silhouettes: spores float, roots erupt, wind coils and support effects ascend.
for _,name in {"SporeBloom","SporeEcho"} do
 local m=groups.Attacks[name];local r=m.PrimaryPart;local diameter=m:GetAttribute("Footprint")
 for i=1,9 do
  local angle=i*math.pi*2/9;local direction=Vector3.new(math.cos(angle),0,math.sin(angle))
  local orb=gfx(m,"LuminousSpore",CFrame.new(direction*diameter*0.17+Vector3.new(0,0.5,0)),Vector3.one*(0.35+i%3*0.16),i%2==0 and C.Mint or C.Violet,nil,"Shard",0.68,0.04)
  comet(orb,C.Violet,0.2,0.6)
  orb.Shape=Enum.PartType.Ball;orb:SetAttribute("VFXVelocity",direction*diameter*0.3+Vector3.new(0,3+i%4,0))
  local a=at(r,"SporePlume"..i,direction*diameter*0.13)
  particle(a,"FungalCloud","Smoke",C.Violet,diameter*0.16,2,0.6,{Speed=NumberRange.new(1,3),Acceleration=Vector3.new(0,2,0),Transparency=seq({0,1},{0.15,0.55},{1,1})})
 end
end
for _,name in {"Spikes","ElderRoots","SentinelRoots"} do
 local m=groups.Attacks[name]
 for _,p in m:GetChildren() do if p:IsA("BasePart") and p.Transparency<1 and not p:GetAttribute("VFXMotion") then
  p:SetAttribute("VFXMotion","Rise");p:SetAttribute("VFXLife",name=="Spikes" and 1 or 0.65)
  p:SetAttribute("VFXVelocity",Vector3.new(0,-p.Size.Y,0));p:SetAttribute("VFXGrowFrom",0.3)
 end end
end
for _,spec in {{"Attacks","TailSpin",20,2},{"Skills","Cyclone",10,1.2}} do
 local m=groups[spec[1]][spec[2]];local r=m.PrimaryPart
 for i=1,3 do
  local height=(i-2)*0.85
  arc(m,CFrame.new(0,height,0)*CFrame.Angles(0,i*1.9,math.rad(6)),spec[3]*(0.32+i*0.045),-1.2,1.6,10,i==2 and C.White or C.Ice,0.38,spec[4],(i-1)*0.025,"Orbit",Vector3.new(0,(i%2==0 and -1 or 1)*7,0))
 end
 for i=1,5 do
  local angle=i*math.pi*2/5
  local pos=Vector3.new(math.cos(angle)*spec[3]*0.3,(i%3-1)*0.65,math.sin(angle)*spec[3]*0.3)
  local tangent=Vector3.new(-math.sin(angle),0,math.cos(angle))
  local a=at(r,"WindStream"..i,pos);a.CFrame=CFrame.lookAt(pos,pos+tangent)
  local e=particle(a,"WindStreaks","Spark",C.Ice,0.55,4,0.36,{Rate=12,EmissionDirection=Enum.NormalId.Front,Speed=NumberRange.new(7,12),SpreadAngle=Vector2.new(12,12),Drag=5,Orientation=Enum.ParticleOrientation.VelocityParallel})
  e:SetAttribute("EmitDuration",spec[4]-0.38)
  local mist=particle(a,"AirMist","Smoke",C.Ice,1.4,2,0.42,{Rate=4,EmissionDirection=Enum.NormalId.Front,Speed=NumberRange.new(3,6),SpreadAngle=Vector2.new(12,12),Transparency=seq({0,1},{0.15,0.78},{1,1})})
  mist:SetAttribute("EmitDuration",spec[4]-0.45)
 end
 light(r,C.Ice,spec[3])
end
for _,name in {"Rush","AntlerRush"} do
 local m=groups.Attacks[name];local r=m.PrimaryPart;local color=name=="Rush" and C.Gold or C.Mint
 for side=-1,1,2 do
  for i=1,3 do
   ray(r,"VelocityRibbon",Vector3.new(side*(1.7+i*0.3),-0.5+i*0.6,-3),Vector3.new(side*(2.1+i*0.35),-0.6+i*0.6,6+i),color,0.12+i*0.055,0.8)
  end
 end
 arc(m,CFrame.new(0,0,-3)*CFrame.Angles(math.pi/2,0,0),3.2,0,math.pi*2,16,color,0.18,0.7,0,"Grow")
end
do
 local m=groups.Attacks.Roar;local r=m.PrimaryPart
 for i=0,2 do
  arc(m,CFrame.new(0,0.25+i*0.2,0),24-i*3,0,math.pi*2,24,i==0 and C.White or C.Gold,0.22,0.72,i*0.1)
 end
 light(r,C.Gold,28)
end
for _,spec in {{"Skills","Blessing",C.Gold},{"Impacts","Regrowth",C.Mint}} do
 local m=groups[spec[1]][spec[2]];local r=m.PrimaryPart
 arc(m,CFrame.new(0,-2.4,0),2.8,0,math.pi*2,20,spec[3],0.12,1,0,"Orbit",Vector3.new(0,1.6,0))
 for i=1,6 do
  local angle=i*math.pi/3;local pos=Vector3.new(math.cos(angle)*2,-2.2,math.sin(angle)*2)
  ray(r,"HealingShaft",pos,pos+Vector3.new(0,6,0),spec[3],0.22,0.75,i*0.025)
  local p=gfx(m,"AscendingMote",CFrame.new(pos)*CFrame.Angles(0,angle,math.pi/4),Vector3.new(0.25,0.5,0.25),C.White,nil,"Shard",1,i*0.025)
  p:SetAttribute("VFXVelocity",Vector3.new(0,4.5,0));p:SetAttribute("VFXAngular",Vector3.new(0,2,0))
 end
 light(r,spec[3],14)
end
for _,m in groups.Statuses:GetChildren() do
 local r=m.PrimaryPart;local color=m.Name=="Safeguard" and C.Ice or m.Name=="Fury" and C.Gold or C.Leaf
 -- Persistent seals use Beams, so repeated status refreshes create no geometry bursts.
 for i=1,4 do
  local a=i*math.pi/2;local b=a+math.pi/2
  ray(r,"WardSegment",Vector3.new(math.cos(a)*2,-1,math.sin(a)*2),Vector3.new(math.cos(b)*2,-1,math.sin(b)*2),color,0.08,5)
 end
 local e=particle(at(r,"AuraFlare",Vector3.new(0,0.3,0)),"AuraFlare","Glow",color,2.6,1,0.6,{Rate=1.5,Transparency=seq({0,1},{0.3,0.85},{1,1})})
end

-- Bound every particle tail to its template's duration (explicit runtime overrides match these).
local total,layers=0,0
for _,g in library:GetChildren() do for _,m in g:GetChildren() do
	total+=1
	local duration=m:GetAttribute("Duration")
	for _,e in m:GetDescendants() do if e:IsA("ParticleEmitter") then
		layers+=1
		local delay=e:GetAttribute("EmitDelay") or 0
		local available=math.max(0.08,duration-delay)
		e.Lifetime=NumberRange.new(math.min(e.Lifetime.Min,available),math.min(e.Lifetime.Max,available))
		local emission=e:GetAttribute("EmitDuration") or 0
		if emission>0 then e:SetAttribute("EmitDuration",math.max(0,available-e.Lifetime.Max)) end
	end end
end end
local backup=SS:FindFirstChild("RPGVFXBackups") or Instance.new("Folder");backup.Name="RPGVFXBackups";backup.Parent=SS
old.Name="CombatVFX_PrePolish_"..os.time();old.Parent=backup
library.Parent=RS.Resources
return string.format("Installed %d templates / %d particle layers; previous templates backed up",total,layers)
