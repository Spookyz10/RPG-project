-- Run once in Edit Mode after syncing the client animation code.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installing")
local RS, SS = game:GetService("ReplicatedStorage"), game:GetService("ServerStorage")
local resources = RS.Resources
local function folder(parent, name)
 local result = parent:FindFirstChild(name) or Instance.new("Folder")
 result.Name = name; result.Parent = parent; return result
end
local backups = folder(folder(SS, "RPGVFXBackups"), "ClientMotion_" .. os.time())
local function install(parent, value)
 local old = parent:FindFirstChild(value.Name)
 if old then old.Parent = backups end
 value.Parent = parent
end
-- Move the original libraries, preserving source poses and existing published IDs.
for _, name in {"Animations", "MobMotion", "PlayerMotion"} do
 local source = SS:FindFirstChild(name)
 if source then install(resources, source) end
 assert(resources:FindFirstChild(name), "Missing library " .. name)
end
local defaults = {Idle="180435571",Jump="125750702",Fall="180436148",Climb="180436334",Sit="178130996"}
for name, id in defaults do
 if not resources.Animations:FindFirstChild(name, true) then
  local animation = Instance.new("Animation")
  animation.Name = name; animation.AnimationId = "rbxassetid://" .. id; animation.Parent = resources.Animations
 end
end
local function p(x,y,z,h)
 return CFrame.new(0,h or 0,0)*CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0))
end
local function pose(torso,right,left)
 return {Torso=torso,Head=p(0),["Right Arm"]=right,["Left Arm"]=left,["Right Leg"]=p(0),["Left Leg"]=p(0)}
end
local basis=CFrame.fromMatrix(Vector3.zero,Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,1,0))
local bases={Torso=basis,Head=basis,["Right Arm"]=CFrame.Angles(0,math.pi/2,0),["Left Arm"]=CFrame.Angles(0,-math.pi/2,0),["Right Leg"]=CFrame.Angles(0,math.pi/2,0),["Left Leg"]=CFrame.Angles(0,-math.pi/2,0)}
local neutral=pose(p(0),p(0,0,8),p(0,0,-8))
local function clip(name, wind, strike, length)
 local sequence=Instance.new("KeyframeSequence")
 sequence.Name=name; sequence.Priority=Enum.AnimationPriority.Action; sequence.Loop=false
 for _, key in {{0,neutral},{0.14,wind},{0.28,strike},{length-0.25,strike},{length,neutral}} do
  local frame=Instance.new("Keyframe");frame.Time=key[1];frame.Parent=sequence
  local root=Instance.new("Pose");root.Name="HumanoidRootPart";root.Weight=0;root.Parent=frame
  local torso=Instance.new("Pose");torso.Name="Torso";torso.Parent=root
  for name, transform in key[2] do
   local value=name=="Torso" and torso or Instance.new("Pose")
   value.Name=name;value.Weight=1;value.EasingStyle=Enum.PoseEasingStyle.Linear
   local x,y,z=transform:ToEulerAnglesXYZ()
   value.CFrame=bases[name]:Inverse()*(CFrame.new(transform.Position)*CFrame.Angles(-x,y,z))*bases[name]
   if name~="Torso" then value.Parent=torso end
  end
 end
 install(resources.PlayerMotion, sequence)
end
clip("Renewal",pose(p(8),p(-40,0,35),p(-40,0,-35)),pose(p(-8),p(-145,0,48),p(-145,0,-48)),1.1)
clip("Arc Breaker",pose(p(-12,-38),p(-150,-30,70),p(-45,20,-30)),pose(p(18,40,0,-0.15),p(-35,65,30),p(-70,-30,-60)),1.05)
local library=resources.CombatVFX
local function effect(group, name, source, color, duration)
 local model=source:Clone();model.Name=name
 model:SetAttribute("Duration",duration);model:SetAttribute("Version",3)
 model:PivotTo(CFrame.identity)
 for _, v in model:GetDescendants() do
  if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
   v.Color=ColorSequence.new(color,color:Lerp(Color3.new(1,1,1),0.5))
  elseif v:IsA("PointLight") then v.Color=color
  elseif v:IsA("BasePart") and v.Material==Enum.Material.Neon then v.Color=color end
 end
 install(library[group],model)
 return model
end
local mint=Color3.fromRGB(100,255,205)
local blue=Color3.fromRGB(100,185,255)
local renewal=effect("Skills","Renewal",library.Skills.Blessing,mint,1.5)
local arc=effect("Skills","Arc Breaker",library.Skills.Basic3,blue,0.85)
local status=effect("Statuses","Renewal",library.Statuses.Safeguard,mint,6)
-- A smaller orbiting healing aura rather than the Safeguard shell.
for _, v in status:GetDescendants() do
 if v:IsA("BasePart") and v.Transparency < 1 then v.Transparency=math.max(v.Transparency,0.72) end
end
local function shard(model, name, cf, size, color, motion, velocity)
 local part=Instance.new("Part");part.Name=name;part.Size=size;part.CFrame=cf
 part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.CastShadow=false
 part.Material=Enum.Material.Neon;part.Color=color;part.Transparency=0.15
 part:SetAttribute("VFXMotion",motion);part:SetAttribute("VFXLife",0.8);part:SetAttribute("VFXGrowFrom",0.2)
 part:SetAttribute("VFXVelocity",velocity or Vector3.zero);part:SetAttribute("VFXAngular",Vector3.new(0,2,0))
 part.Parent=model
 return part
end
for i=1,8 do
 local angle=i*math.pi/4
 shard(renewal,"HealingOrbit",CFrame.new(math.cos(angle)*3,0.4,math.sin(angle)*3),Vector3.new(0.18,1.1,0.18),mint,"Orbit")
end
for i=0,12 do
 local angle=math.rad(-75+i*12.5)
 local cf=CFrame.new(math.sin(angle)*7,0,-math.cos(angle)*4)*CFrame.Angles(0,-angle,math.rad(20))
 shard(arc,"ArcFragment",cf,Vector3.new(0.8,0.22,2.5),blue,"Shard",Vector3.new(math.sin(angle)*7,0,-6))
end
for _, model in {renewal,arc} do
 local root=model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart",true)
 local light=Instance.new("PointLight");light.Color=model==arc and blue or mint
 light.Brightness=3;light.Range=18;light.Enabled=false;light:SetAttribute("VFXLife",0.35);light.Parent=root
end
-- Upgrade the previous temporary verification script when present, preserving a backup.
local verification=game:GetService("ServerScriptService"):FindFirstChild("FinalCombatVerification")
if verification and verification:IsA("Script") and verification.Source:find("client source exposed",1,true) then
 verification:Clone().Parent=backups
 local source=verification.Source
 source=source:gsub("local library=SS%.PlayerMotion","local library=game.ReplicatedStorage.Resources.PlayerMotion")
 source=source:gsub("SS%.MobMotion","game.ReplicatedStorage.Resources.MobMotion")
 source=source:gsub('for _,v in game.ReplicatedStorage:GetDescendants%(%) do assert%(not v:IsA%("KeyframeSequence"%),"client source exposed: "%.%.v:GetFullName%(%)%) end',
  'assert(not SS:FindFirstChild("PlayerMotion") and not SS:FindFirstChild("MobMotion"),"legacy server motion libraries")')
 source=source:gsub("server%-only sequences","client-owned sequences")
 verification.Source=source
end
return "Client libraries installed; Renewal and Arc Breaker sequences, cast VFX and Renewal status authored. Backups: " .. backups:GetFullName()
