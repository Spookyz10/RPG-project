"""Run real Forest attack/data modules in Luau; physics and visual QA still require Studio."""
import argparse
from pathlib import Path
import subprocess
import tempfile
p=argparse.ArgumentParser();p.add_argument('--luau',required=True);args=p.parse_args()
root=Path(__file__).resolve().parents[1]
source=r'''
local mt={}
local function v(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},mt) end
mt.__add=function(a,b) return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
mt.__sub=function(a,b) return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
mt.__mul=function(a,b) return v(a.X*b,a.Y*b,a.Z*b) end
mt.__index=function(a,k) if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end end
local cmt={}
local function cf(x,y,z) return setmetatable({Position=type(x)=="table" and x or v(x,y,z),LookVector=v(0,0,-1)},cmt) end
cmt.__mul=function(a,b) return cf(a.Position+b.Position) end
cmt.__add=function(a,b) return cf(a.Position+b) end
local players={}
local wall=false
local heartbeat={Wait=function() return .1 end}
local rs={Shared={Utils={Types={},RemoteManager={}}}}
local env=setmetatable({
 Vector3={new=v,zero=v()}, CFrame={new=cf},require=function(x) return x end,
 game={GetService=function(_,name)
  if name=="Players" then return {GetPlayers=function() return players end} end
  if name=="RunService" then return {Heartbeat=heartbeat} end
  return rs
 end},
 workspace={Blockcast=function() return wall end},
},{__index=getfenv()})
local function load(source,script)
 local fn=assert(loadstring(source));setfenv(fn,setmetatable({script=script},{__index=env}));return fn()
end
local attacks={}
ATTACKS
local function context(cancelAt)
 local elapsed=0
 local log={Hits={},Indicators={},Effects={}}
 local ctx={Root={CFrame=cf(),Position=v()},Config={},RaycastParams={}}
 ctx.Active=function() return not cancelAt or elapsed<cancelAt end
 ctx.Alive=function(char) return char.Alive end
 ctx.Ground=function(x) return x end
 ctx.Pause=function(t) elapsed+=t;return ctx.Active() end
 ctx.Indicator=function(...) table.insert(log.Indicators,{...}) end
 ctx.Hit=function(...) assert(ctx.Active());table.insert(log.Hits,{...}) end
 ctx.VFX=function(...) table.insert(log.Effects,{...}) end
 return ctx,log
end
local spec={Radius=7,Pulses=2,Windup=1.2,Multiplier=1.2,Effect="SporeBloom"}
local ctx,log=context();attacks.ForestBurst(ctx,spec)
assert(#log.Indicators==2 and #log.Hits==2)
assert(log.Hits[1][3]==7 and log.Hits[2][3]==10)
assert(log.Hits[1][7]==log.Hits[2][7],"spore pulses must share deduplication")
ctx,log=context(.1);attacks.ForestBurst(ctx,spec);assert(#log.Hits==0)
ctx,log=context(1.5);attacks.ForestBurst(ctx,spec);assert(#log.Hits==1)
ctx,log=context();attacks.RootLanes(ctx)
assert(#log.Hits==2 and log.Indicators[1][4]==1.1 and log.Indicators[2][4]==1.8)
assert(log.Hits[1][1].Position.X==-6 and log.Hits[2][1].Position.X==6)
ctx,log=context(1.5);attacks.RootLanes(ctx);assert(#log.Hits==1)
local function player(id,distance,alive)
 local part={Position=v(distance,0,0)}
 return {UserId=id,Character={Alive=alive,FindFirstChild=function() return part end}}
end
players={player(1,40,true),player(2,10,true),player(3,20,true),player(4,30,true),player(5,2,false),player(6,90,true)}
ctx,log=context();attacks.MarkedRoots(ctx)
assert(#log.Hits==3 and log.Hits[1][1].Position.X==10 and log.Hits[3][1].Position.X==30)
assert(log.Hits[1][7]==log.Hits[3][7],"overlapping roots cannot multiply rewards/damage")
ctx,log=context(.1);attacks.MarkedRoots(ctx);assert(#log.Hits==0)
players={};ctx,log=context();attacks.MarkedRoots(ctx);assert(#log.Hits==0)
ctx,log=context();attacks.AntlerRush(ctx);assert(math.abs(ctx.Root.CFrame.Position.Z+26)<.001)
assert(#log.Hits>1 and log.Hits[1][7]==log.Hits[#log.Hits][7])
wall=true;ctx,log=context();attacks.AntlerRush(ctx);assert(#log.Hits==0 and ctx.Root.CFrame.Position.Z==0);wall=false
ctx,log=context(.1);attacks.AntlerRush(ctx);assert(#log.Hits==0)
ctx,log=context();attacks.Melee(ctx,{Name="RootSweep",Size=v(26,18,20),Effect="RootSweep",Windup=1.2,Multiplier=1.4})
assert(log.Effects[1][1]=="RootSweep" and log.Hits[1][4]==1.4)
local config=load([====[CONFIG]====])
rs.Shared.MobCombatConfig=config
local definitions={}
local controller={Start=function(_,mob,def) assert(def.Config and def.Basic.Execute and #def.Skills>0) end}
local attackRoot={Controller=controller,Attacks=attacks}
BEHAVIORS
local items={}
ITEMS
local mobs={}
MOBS
local recipes=load([====[RECIPES]====])
for name,mob in mobs do
 assert(mob.Data.Stats.Health==config[name].Health)
 assert(mob.Data.Stats.Attack>0 and not mob.GlobalDrops)
 for id,drop in mob.Drops do assert(items[id] and drop.Chance>0 and drop.Chance<=100 and drop.Amount>=1) end
 definitions[name]:Start({})
end
for _,name in {
 "Sporeweave Mantle","Sporethorn Daggers","Thornwood Blade","Rune of Resonance","Sentinel Signet",
 "Runebark Vestment","Grovekeeper Charm","Heartwood Cleaver",
} do
 local recipe=recipes[name];assert(items[name] and recipe.Level==items[name].Data.Level)
 for id,amount in recipe.Ingredients do assert(items[id] and amount>0 and amount<=items[id].Data.Cap) end
end
for _,name in {"Sporecap Pendant","Bramble Loop","Moonwater Pendant","Heart of the Grove"} do
 assert(items[name] and not recipes[name],name.." must remain drop-exclusive")
end
for _,mob in mobs do
 for id in mob.Drops do assert(not recipes[id],id.." cannot be both a mob drop and a crafted result") end
end
assert(config.Elderbark.IsBoss and config.Elderbark.SkillRecovery==5)
-- Execute the production controller with simulated time: optional recovery must not change old mobs.
for _,recovery in {0,5} do
 local now=0
 env.os={clock=function() return now end}
 env.warn=error
 env.workspace.FindFirstChild=function() return nil end
 local times={}
 local body={Position=v(),CFrame=cf()}
 local hum={Health=100}
 local attrs={}
 local mob={Parent=true,FindFirstChild=function(_,name) if name=="HumanoidRootPart" then return body end end,
 FindFirstChildOfClass=function() return hum end,GetAttribute=function(_,name) return attrs[name] end,
 SetAttribute=function(_,name,value) attrs[name]=value end}
 local behavior={Active={}}
 local contextModule={new=function()
  return {Active=function() return now<6 end,Alive=function() return true end,
   RefreshFilter=function() end,Pause=function(dt) now+=dt;return now<6 end}
 end}
 local pursuit={new=function() return {Update=function() return true end,Stop=function() end,MeleeReach=6} end}
 local facing={new=function() return {Towards=function() return true end,Release=function() end,Destroy=function() end} end}
 local actual=load([====[CONTROLLER]====],{Parent={BehaviorManager=behavior,CombatContext=contextModule,Pursuit=pursuit,Facing=facing}})
 players={player(1,5,true)}
 local execute=function() table.insert(times,now) end
 actual:Start(mob,{Config={Speed=9,BasicCooldown=1,SkillRecovery=recovery},
  Basic={Name="Basic",Execute=function() end},Skills={{Name="A",Execute=execute,Cooldown=20},{Name="B",Execute=execute,Cooldown=20}}})
 assert(#times==2)
 assert(recovery==0 and times[2]<1 or recovery==5 and times[2]>=5,"global skill recovery regression")
 assert(behavior.Active[mob]==nil and hum.AutoRotate==true,"controller cleanup")
end
print("PASS: Forest cancellations, pulse deduplication, alternating lanes, nearest-three roots, blocked charge, effect routing, behaviors, drops and recipes")
'''
attacks=['ForestBurst','RootLanes','MarkedRoots','AntlerRush','Melee']
source=source.replace('ATTACKS','\n'.join(f'attacks.{name}=load([====[{(root/f"Common/src/Modules/Mobs/Attacks/{name}.luau").read_text()}]====])' for name in attacks))
source=source.replace('CONTROLLER',(root/'Common/src/Modules/Mobs/Controller.luau').read_text())
source=source.replace('CONFIG',(root/'Common/src/Shared/MobCombatConfig.luau').read_text()).replace('RECIPES',(root/'Common/src/Shared/CraftingRecipes.luau').read_text())
names=['Mosscap','Thornback Stag','Hollow Sentinel','Elderbark']
source=source.replace('BEHAVIORS','\n'.join(f'definitions["{n}"]=load([====[{(root/f"Common/src/Modules/Mobs/Behaviors/{n}.luau").read_text()}]====],{{Parent={{Parent=attackRoot}}}})' for n in names))
source=source.replace('MOBS','\n'.join(f'mobs["{n}"]=load([====[{(root/f"Common/src/Shared/MobsData/Forest/{n}.luau").read_text()}]====])' for n in names))
source=source.replace('ITEMS','\n'.join(f'do local item=load([====[{p.read_text()}]====],{{Name="{p.stem}"}});items[item.Data.ID]=item end' for p in (root/'Common/src/Shared/ItemsData').rglob('*.luau') if p.stem!='init'))
with tempfile.TemporaryDirectory(prefix='forest-combat-') as tmp:
 path=Path(tmp)/'test.luau';path.write_text(source,encoding='utf-8')
 raise SystemExit(subprocess.run([args.luau,str(path)]).returncode)
