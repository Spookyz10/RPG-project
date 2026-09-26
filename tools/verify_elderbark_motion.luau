-- Run as a temporary server Script during Play, sharing the normal require cache.
-- Exercises production attacks without damage or saves.
local SS = game:GetService("ServerStorage")
local attacks = SS.Modules.Mobs.Attacks
local function context(cancelAt)
 local elapsed=0
 local log={Hits={},Indicators={},Effects={}}
 local root={CFrame=CFrame.new(0,0,0),Position=Vector3.zero}
 local ctx={Root=root,Config={},MeleeReach=12}
 ctx.Active=function() return not cancelAt or elapsed<cancelAt end
 ctx.Alive=function(char) local h=char:FindFirstChildOfClass("Humanoid");return h and h.Health>0 end
 ctx.Ground=function(cf) return cf end
 ctx.Pause=function(dt) elapsed+=dt;return ctx.Active() end
 ctx.Indicator=function(...) table.insert(log.Indicators,{...}) end
 ctx.Hit=function(...) assert(ctx.Active(),"hit after cancellation");table.insert(log.Hits,{...}) end
 ctx.VFX=function(...) table.insert(log.Effects,{...}) end
 return ctx,log
end
local patterns=require(attacks.ElderPatterns)
for pattern,count in {Fan=10,Rupture=16,Cascade=4} do
 local spec={Name=pattern,Pattern=pattern,Windup=.85,Multiplier=1.4}
 local ctx,log=context();patterns(ctx,spec)
 assert(#log.Hits==count and #log.Indicators==count,pattern)
 for i,hit in log.Hits do assert(log.Indicators[i][2]==hit[1],"telegraph and hit differ") end
 if pattern~="Cascade" then assert(log.Hits[1][7]==log.Hits[2][7],"overlap dedup") end
 for _,cancel in {.1,1,1.8,2.7} do
  ctx,log=context(cancel);patterns(ctx,spec)
  assert(#log.Hits<count or cancel>2.0 and pattern~="Cascade","cancellation")
 end
end
local burst=require(attacks.ForestBurst)
local ctx,log=context();burst(ctx,{Radius=21,Windup=1.05,Pulses=2,PulseGap=.65,RepeatDamage=true,Effect="HeartSlam",EchoEffect="HeartEcho"})
assert(#log.Hits==2 and log.Hits[1][7]~=log.Hits[2][7] and log.Hits[2][3]==24,"slam echo damage and radius")
ctx,log=context();burst(ctx,{Pulses=2,Effect="SporeBloom"})
assert(log.Hits[1][7]==log.Hits[2][7],"Mosscap behavior changed")
ctx,log=context(.1);burst(ctx,{Pulses=2});assert(#log.Hits==0,"cancelled slam dealt damage")
local resources=game.ReplicatedStorage.Resources
local library=resources.PlayerMotion
for _,name in {"Attack1","Attack2","Attack3","DAttack1","DAttack2","DAttack3","Cyclone","Ground Break","Lure Jab","Blessing","Safeguard","Renewal","Arc Breaker"} do
 local clip=assert(library:FindFirstChild(name),name)
 assert(clip:IsA("KeyframeSequence") and not clip.Loop,"clip must be a one-shot: "..name)
 local frames=clip:GetKeyframes();assert(#frames>=5,"clip keyframes: "..name)
 for _,frame in frames do assert(frame:FindFirstChild("HumanoidRootPart"),"pose hierarchy") end
end
local definition=require(SS.Modules.Mobs.Behaviors.Elderbark)
assert(#definition.Skills==6 and definition.Config.EnragedRecovery<definition.Config.SkillRecovery,"boss skill count and enrage recovery")
for _,skill in definition.Skills do assert(resources.MobMotion.Elderbark:FindFirstChild(skill.Name),skill.Name) end
assert(not SS:FindFirstChild("PlayerMotion") and not SS:FindFirstChild("MobMotion"),"legacy server motion libraries")
return "PASS: six skills, hit/telegraph positions, stage deduplication, cancellation, preserved Mosscap pulses, 13 player clips, boss animation coverage, client-owned sequences"
