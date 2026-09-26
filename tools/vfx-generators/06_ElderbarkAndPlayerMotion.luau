-- Run in Edit Mode. Client playback reads editable sequences from Resources.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local SS, RS = game:GetService("ServerStorage"), game:GetService("ReplicatedStorage")
local resources = RS.Resources
local function folder(parent, name)
 local f = parent:FindFirstChild(name) or Instance.new("Folder")
 f.Name = name; f.Parent = parent; return f
end
local backup = folder(folder(SS, "RPGVFXBackups"), "CombatMotion_" .. os.time())
local function install(parent, object)
 local old = parent:FindFirstChild(object.Name)
 if old then old.Parent = backup end
 object.Parent = parent
end
for _, name in {"MobMotion", "Animations"} do
 local source = SS:FindFirstChild(name)
 if source then install(resources, source) end
end
-- Published IDs needed only for UI mannequins are not editable motion source.
local previews = folder(resources, "AnimationPreviews")
local idle = resources.Animations:FindFirstChild("Solo", true)
if idle and not previews:FindFirstChild("Solo") then idle:Clone().Parent = previews end
local legacy = RS:FindFirstChild("SwordAttack")
if legacy then legacy.Parent = backup end
local playerLibrary = Instance.new("Folder"); playerLibrary.Name = "PlayerMotion"
local function p(x,y,z,h,f)
 return CFrame.new(0,h or 0,f or 0)*CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0))
end
local function playerPose(torso, right, left, legs)
 return {Torso=torso, Head=p(0,0,0), ["Right Arm"]=right, ["Left Arm"]=left,
  ["Right Leg"]=legs or p(0), ["Left Leg"]=legs and legs:Inverse() or p(0)}
end
local neutral=playerPose(p(0),p(0,0,8),p(0,0,-8))
local rootBasis=CFrame.fromMatrix(Vector3.zero,Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,1,0))
local playerBases={Torso=rootBasis,Head=rootBasis,["Right Arm"]=CFrame.Angles(0,math.pi/2,0),["Left Arm"]=CFrame.Angles(0,-math.pi/2,0),["Right Leg"]=CFrame.Angles(0,math.pi/2,0),["Left Leg"]=CFrame.Angles(0,-math.pi/2,0)}
local function clip(parent,name,keys,parents)
 local seq=Instance.new("KeyframeSequence");seq.Name=name;seq.Loop=false;seq.Priority=Enum.AnimationPriority.Action
 for _,key in keys do
  local frame=Instance.new("Keyframe");frame.Time=key[1];frame.Parent=seq
  local made={}
  local function pose(name)
   if made[name] then return made[name] end
   local value=Instance.new("Pose");value.Name=name;made[name]=value
   local transform=key[2][name] or CFrame.identity
   if parent==playerLibrary and playerBases[name] then
    -- Author in character axes, then convert into the R6 joint coordinate frame.
    local x,y,z=transform:ToEulerAnglesXYZ()
    local authored=CFrame.new(transform.Position)*CFrame.Angles(-x,y,z)
    local basis=playerBases[name]
    transform=basis:Inverse()*authored*basis
   end
   value.CFrame=transform;value.Weight=name=="HumanoidRootPart" and 0 or 1
   value.EasingStyle=Enum.PoseEasingStyle.Linear
   value.Parent=parents[name] and pose(parents[name]) or frame
   return value
  end
  for name in parents do pose(name) end
 end
 install(parent,seq)
 return seq
end
local r6={Torso="HumanoidRootPart",Head="Torso",["Right Arm"]="Torso",["Left Arm"]="Torso",["Right Leg"]="Torso",["Left Leg"]="Torso"}
local swings={
 {"Attack1",playerPose(p(-4,-25,-5),p(-75,-45,90),p(15,0,-25),p(-8)),playerPose(p(8,32,10),p(-30,55,35),p(-15,0,-18),p(12))},
 {"Attack2",playerPose(p(-3,28,8),p(-30,65,25),p(-10,0,-18),p(6)),playerPose(p(5,-35,-9),p(-95,-45,100),p(20,-10,-28),p(-12))},
 {"Attack3",playerPose(p(-15,0,0),p(-160,0,18),p(-55,0,-22),p(-10)),playerPose(p(24,0,0,-0.16),p(-45,0,8),p(12,0,-25),p(16))},
 {"DAttack1",playerPose(p(-4,-28,-6),p(-85,-30,75),p(-25,15,-30),p(-10)),playerPose(p(8,30,9),p(-35,55,30),p(-65,-30,-65),p(12))},
 {"DAttack2",playerPose(p(-4,28,6),p(-25,-15,30),p(-85,30,-75),p(10)),playerPose(p(8,-30,-9),p(-65,30,65),p(-35,-55,-30),p(-12))},
 {"DAttack3",playerPose(p(-12,0,0),p(-125,-25,75),p(-125,25,-75),p(-12)),playerPose(p(20,0,0,-0.12),p(-40,45,-20),p(-40,-45,20),p(15))},
}
for _,entry in swings do
 clip(playerLibrary,entry[1],{{0,neutral},{0.10,entry[2]},{0.18,entry[2]},{0.26,entry[3]},{0.34,entry[3]},{0.56,neutral}},r6)
end
local casts={
 {"Ground Break",playerPose(p(-18,0,0),p(-165,0,15),p(-80,0,-25)),playerPose(p(28,0,0,-0.25),p(-40,0,12),p(15,0,-25)),0.85},
 {"Lure Jab",playerPose(p(-6,-20,0),p(-40,-35,65),p(-20,0,-25)),playerPose(p(12,25,0,0,-0.2),p(-90,0,0),p(15,0,-22)),0.7},
 {"Blessing",playerPose(p(-5,0,0),p(-35,0,30),p(-35,0,-30)),playerPose(p(-10,0,0),p(-130,0,35),p(-130,0,-35)),1.0},
 {"Safeguard",playerPose(p(0,0,0),p(-35,0,25),p(-35,0,-25)),playerPose(p(5,0,0),p(-90,-30,-35),p(-90,30,35)),0.9},
}
for _,entry in casts do
 clip(playerLibrary,entry[1],{{0,neutral},{0.14,entry[2]},{0.28,entry[3]},{entry[4]-.22,entry[3]},{entry[4],neutral}},r6)
end
local spinKeys={{0,neutral}}
for i=0,12 do
 local t=0.12+i*0.09
 table.insert(spinKeys,{t,playerPose(p(0,i*90,0,-0.12),p(-60,0,75),p(-60,0,-75),p(8))})
end
table.insert(spinKeys,{1.45,neutral})
clip(playerLibrary,"Cyclone",spinKeys,r6)
install(resources,playerLibrary)
local boss=RS.Mobs:FindFirstChild("Elderbark",true)
local parents={}
for _,j in boss:GetDescendants() do if j:IsA("Motor6D") and j.Part0 and j.Part1 then parents[j.Part1.Name]=j.Part0.Name end end
local lib=resources.MobMotion.Elderbark
lib:SetAttribute("WalkSpeed",12)
local function bossPose(lean,twist,lift,spread,crouch)
 return {Torso=p(lean,twist,0,crouch),Head=p(-lean*.5,-twist*.4),
 RightArm=p(lift,0,spread),LeftArm=p(lift,0,-spread),RightForearm=p(-20),LeftForearm=p(-20),
 RightLeg=p(-lean*.2),LeftLeg=p(lean*.2)}
end
local rest=bossPose(0,0,0,4,0)
local function repeated(name,windup,gap,count,wind,strike,finish)
 local keys={{0,rest}}
 for i=1,count do
  local hit=windup+(i-1)*gap
  table.insert(keys,{hit-.20,wind});table.insert(keys,{hit-.08,wind})
  table.insert(keys,{hit,strike});table.insert(keys,{hit+.10,strike})
 end
 table.insert(keys,{finish,rest});clip(lib,name,keys,parents)
end
repeated("Basic",.6,0,1,bossPose(-8,-24,-75,20,.1),bossPose(14,28,30,15,-.2),.85)
repeated("HeartSlam",1.05,.65,2,bossPose(-18,0,-150,18,.35),bossPose(26,0,20,8,-.5),1.94)
repeated("MarkedRoots",.85,.85,3,bossPose(-8,0,-70,55,.18),bossPose(12,0,-30,25,-.1),2.8)
repeated("RootSweep",.7,.85,2,bossPose(-5,-38,-50,70,.1),bossPose(9,45,10,35,-.15),1.82)
repeated("ThornFan",.85,.97,2,bossPose(-12,0,-100,55,.2),bossPose(14,0,-35,80,-.18),2.08)
repeated("GroveRupture",.95,1.07,2,bossPose(-16,0,-140,30,.3),bossPose(20,0,0,65,-.4),2.3)
repeated("RootCascade",.75,.87,4,bossPose(-10,-15,-90,25,.15),bossPose(18,20,-10,40,-.3),3.65)
-- Templates use the existing VFX runtime, including per-part rise/dissolve and cleanup.
local attacks=resources.CombatVFX.Attacks
local function effect(name,width,length,circle)
 local original
 -- Preserve the authored particle/beam treatment when extending an existing skill.
 for _,candidate in SS.RPGVFXBackups:GetDescendants() do
  if candidate:IsA("Model") and candidate.Name==name and (candidate:GetAttribute("Version") or 0)>=2
   and candidate:FindFirstChildWhichIsA("ParticleEmitter",true) and not candidate:GetAttribute("ElderUpgrade") then
   original=candidate;break
  end
 end
 local current=attacks:FindFirstChild(name)
 if current and current:FindFirstChildWhichIsA("ParticleEmitter",true) and not current:GetAttribute("ElderUpgrade") then original=current end
 local model=original and original:Clone() or Instance.new("Model")
 model.Name=name;model:SetAttribute("Version",2);model:SetAttribute("Duration",.65);model:SetAttribute("ElderUpgrade",true)
 local count=circle and 16 or 14
 for i=1,count do
  local angle=i*math.pi*2/count
  local x=circle and math.sin(angle)*width*.46 or ((i%2==0 and 1 or -1)*width*.32)
  local z=circle and math.cos(angle)*length*.46 or (-length/2+(i-.5)*length/count)
  local thorn=Instance.new("WedgePart");thorn.Name="HeartwoodThorn";thorn.Anchored=true
  thorn.CastShadow=false;thorn.CanCollide=false;thorn.CanTouch=false;thorn.CanQuery=false;thorn.Material=Enum.Material.Wood
  thorn.Color=Color3.fromRGB(64,81,35);thorn.Size=Vector3.new(1.3,7+(i%3),1.3)
  thorn.CFrame=CFrame.new(x,thorn.Size.Y/2,z)*CFrame.Angles(.15*math.sin(angle),angle,.18*math.cos(angle))
  thorn:SetAttribute("VFXMotion","Rise");thorn:SetAttribute("VFXVelocity",Vector3.new(0,-8,0));thorn:SetAttribute("VFXLife",.65)
  thorn:SetAttribute("VFXGrowFrom",.2);thorn.Parent=model
  local glow=Instance.new("Part");glow.Name="SapSpark";glow.Shape=Enum.PartType.Ball;glow.Anchored=true
  glow.CastShadow=false;glow.CanCollide=false;glow.CanTouch=false;glow.CanQuery=false;glow.Material=Enum.Material.Neon
  glow.Color=Color3.fromRGB(191,255,74);glow.Size=Vector3.new(.6,.6,.6);glow.CFrame=CFrame.new(x,1,z)
  glow:SetAttribute("VFXMotion","Shard");glow:SetAttribute("VFXVelocity",Vector3.new(math.sin(angle)*4,12,math.cos(angle)*4))
  glow:SetAttribute("VFXGravity",25);glow:SetAttribute("VFXLife",.65);glow.Parent=model
 end
 model.WorldPivot=CFrame.identity
 install(attacks,model)
end
effect("HeartSlam",42,42,true)
effect("ElderRoots",16,16,true)
effect("RootSweep",32,27,false)
effect("HeartEcho",48,48,true)
effect("ThornFan",9,72,false)
effect("GroveRupture",22,22,true)
effect("RootCascade",44,18,false)
return "Installed 11 player clips, 7 Elderbark combat clips and 7 VFX; editable motion stored on server."
