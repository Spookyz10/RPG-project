-- Read-only production-module harness; run in Studio Edit Mode via execute_luau.
-- All gameplay objects and services are tables; no player data, Instances or saves change.
local SS, RS = game:GetService("ServerStorage"), game:GetService("ReplicatedStorage")
local function load(module, overrides)
 local env = setmetatable(overrides or {}, {__index=getfenv()})
 env.require = function(value) return value end
 local fn = assert(loadstring(module.Source, "=" .. module:GetFullName()))
 setfenv(fn,env)
 return fn()
end
local modifiers = load(SS.Modules.ModifierSystem)
local definitions = load(RS.Shared.StatusEffects)
local events = {Fire=function() end}
local healed = 0
local healing = {heal=function(_, _, target, amount)
 local hum=target.Humanoid
 local delta=math.min(amount, hum.MaxHealth-hum.Health)
 hum.Health+=delta; healed+=delta
end}
local renewal = load(SS.Modules.StatusEffectBehaviors.Renewal, {script={Parent={Parent={DamageHandler=healing}}}})
local manager = load(SS.Modules.StatusEffectManager, {
 game={GetService=function() return {Shared={StatusEffects=definitions}} end},
 script={Parent={StatusEffectBehaviors={Renewal=renewal},ModifierSystem=modifiers,EventBus=events}},
})
local function entity(attack, defense, health)
 local hum={Health=health or 1000,MaxHealth=1000}
 return {Parent=true,Humanoid=hum,Stats={Attack=attack or 20,Defense=defense or 0,Critical=0},
  FindFirstChildOfClass=function() return hum end,SetAttribute=function() end}
end
local victim=entity()
manager:Apply(victim,"Lure Jab")
assert(modifiers:Aggregate(victim,"Defense",0)==-10,"negative defense")
manager:Apply(victim,"Lure Jab")
assert(modifiers:Aggregate(victim,"Defense",20)==10,"refresh must not stack")
local functions={GetTotalStats=function(_, target) return target.Stats end}
local data={Service={waitForData=function() error("must not load data") end}}
local shared={Data={server=data},Utils={Functions=functions,RemoteManager={},Types={}}}
local damage=load(SS.Modules.DamageHandler,{
 game={GetService=function(_,name)
  if name=="Players" then return {GetPlayerFromCharacter=function() return nil end} end
  return {Shared=shared}
 end},
 script={Parent={ModifierSystem=modifiers,EventBus=events,EquipmentPassives={}}},
})
local caster=entity(20)
for _, defense in {0,10,20,10000} do
 victim.Stats.Defense=defense
 local debuffed=damage:BuildContext(caster,victim).Damage
 manager:Remove(victim,"Lure Jab")
 local normal=damage:BuildContext(caster,victim).Damage
 assert(math.abs(debuffed-normal-10)<1e-6,"expected exactly +10 at defense "..defense)
 manager:Apply(victim,"Lure Jab")
end
manager:Step(os.clock()+6)
assert(not manager:HasEffect(victim,"Lure Jab"),"debuff expiration")
assert(modifiers:Aggregate(victim,"Defense",0)==0,"defense restored")
local ally=entity(20,0,100)
manager:Apply(ally,"Renewal")
local effect=manager:Get(ally,"Renewal")
manager:Step(effect.ExpiresAt)
assert(healed==300 and ally.Humanoid.Health==400,"six healing ticks")
assert(not manager:HasEffect(ally,"Renewal"),"healing expiration")
manager:Apply(ally,"Renewal")
manager:Apply(ally,"Renewal")
local refresh=manager:Get(ally,"Renewal")
manager:Step(refresh.NextTick)
assert(healed==350,"refresh must not duplicate healing")
ally.Humanoid.Health=0
manager:Step(refresh.NextTick+1)
assert(not manager:HasEffect(ally,"Renewal") and healed==350,"death cleanup")
for _, name in {"Renewal","Arc Breaker"} do
 local skill=load(RS.Shared.Skills[name],{script={Name=name},game={GetService=function() return {Shared={Utils={Types={}}}} end}})
 assert(not skill:Elligable({Level=skill.LevelRequirement-1}) and skill:Elligable({Level=skill.LevelRequirement}),"level gate")
end
-- Exercise the actual client scheduler against fake rigs and the authored clips.
local now, step = 0, nil
local function signal()
 return {Connect=function(_, callback) return {Disconnect=function() end} end}
end
local fakeWorkspace={GetServerTimeNow=function() return now end,CurrentCamera={CFrame=CFrame.identity}}
local resources=RS.Resources:FindFirstChild("PlayerMotion") and RS.Resources or SS
local motion=load(RS.Shared.MobAnimations,{
 game={GetService=function(_,name)
  if name=="RunService" then return {IsClient=function() return true end,PreSimulation={Connect=function(_,fn) step=fn; return {Disconnect=function() end} end}} end
  return {WaitForChild=function() return resources end}
 end},workspace=fakeWorkspace,
})
motion:Preload()
local function rig(name, partNames)
 local attributes={}
 local joints={}
 for _, name in partNames do
  table.insert(joints,{Part1={Name=name},Parent=true,Transform=CFrame.identity,C0=CFrame.new(1,2,3),IsA=function(_,class) return class=="Motor6D" end})
 end
 local root={Position=Vector3.zero,Parent=true}
 local hum={Health=100,WalkSpeed=12,Parent=true,Died=signal()}
 local model={Name=name,Parent=true,Destroying=signal(),DescendantAdded=signal()}
 model.FindFirstChild=function(_,key) return key=="HumanoidRootPart" and root end
 model.FindFirstChildOfClass=function() return hum end
 model.GetScale=function() return 1 end
 model.GetDescendants=function() return joints end
 model.SetAttribute=function(_,key,value) attributes[key]=value end
 model.GetAttribute=function(_,key) return attributes[key] end
 model.IsDescendantOf=function() return model.Parent~=nil end
 return model,joints,hum,root
end
local playerRig,joints=rig("Player",{"Torso","Right Arm","Left Arm","Head","Right Leg","Left Leg"})
assert(motion:Play(playerRig,"Ground Break",0)>0,"player cast did not attach")
assert(playerRig:GetAttribute("ClientMotion")=="Ground Break","locomotion suppression")
now=0.28;step(0.28)
assert(joints[2].Transform~=CFrame.identity,"cast poses did not animate")
for _,joint in joints do assert(joint.C0==CFrame.new(1,2,3),"animation modified replicated C0") end
now=1;step(0.1)
assert(playerRig:GetAttribute("ClientMotion")==nil,"cast cleanup")
for _,joint in joints do assert(joint.Transform==CFrame.identity,"pose reset") end
assert(motion:Play(playerRig,"Ground Break",0)==0,"expired packet replayed")
now=2
motion:Play(playerRig,"Blessing",2.01)
playerRig.Parent=nil;step(0.02)
assert(playerRig:GetAttribute("ClientMotion")==nil,"removed character kept motion")
local mob,mobJoints,hum,root=rig("Boar",{"Torso","Head","RightLeg","LeftLeg"})
motion:Attach(mob)
now=3;root.Position=Vector3.new(1,0,0);step(0.1)
assert(mobJoints[1].Transform~=CFrame.identity,"mob locomotion did not animate")
hum.Health=0;step(0.1)
for _,joint in mobJoints do assert(joint.Transform==CFrame.identity,"mob death did not reset pose") end
-- Ground projection never falls back to the caster's height and ignores non-solid hitboxes.
local surface={Position=Vector3.zero,Normal=Vector3.yAxis}
local castOrigin=CFrame.new(10,50,20)
local vfx=load(RS.Shared.CombatVFX,{
 game={GetService=function(_,name)
  if name=="RunService" then return {IsClient=function() return false end} end
  if name=="Players" then return {GetPlayers=function() return {} end} end
  return {}
 end},
 workspace={FindFirstChild=function() return nil end,Raycast=function(_,origin,direction,params)
  assert(origin==castOrigin.Position and direction.Y<0 and params.RespectCanCollide,"ground query includes hitboxes or wrong origin")
  return surface
 end},
})
local grounded=vfx:Ground(castOrigin)
assert(math.abs(grounded.Position.Y-0.08)<1e-6,"ground projection at player height")
surface={Position=Vector3.new(0,2,0),Normal=Vector3.new(0,1,0.5).Unit}
grounded=vfx:Ground(castOrigin)
assert(grounded.UpVector:Dot(surface.Normal)>0.999,"slope alignment")
surface=nil
assert(vfx:Ground(castOrigin)==nil,"missing ground produced floating effect")
return "PASS: flat +10, negative defense, debuff expiration, six healing ticks, refresh/death cleanup, level gates, client cast poses, C0 untouched, expired packets, respawn/mob cleanup, ground/slope/no-surface projection."
