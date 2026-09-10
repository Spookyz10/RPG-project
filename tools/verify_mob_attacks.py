"""Exercise production mob attack modules and behavior registration without Studio physics."""
import argparse
from pathlib import Path
import subprocess
import tempfile

p = argparse.ArgumentParser()
p.add_argument('--luau', required=True)
args = p.parse_args()
root = Path(__file__).resolve().parents[1]
source = r'''
local now = 0
local vectorMT = {}
local function vector(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0}, vectorMT) end
vectorMT.__add=function(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vectorMT.__sub=function(a,b) return vector(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vectorMT.__mul=function(a,b) return vector(a.X*b,a.Y*b,a.Z*b) end
vectorMT.__index=function(a,k) if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end end
local cfMT = {}
local function cf() return setmetatable({LookVector=vector(0,0,-1),Position=vector()},cfMT) end
cfMT.__mul=function(a) return a end
cfMT.__add=function(a) return a end
local heartbeat={Wait=function() now+=0.1; return 0.1 end}
local animations={PlayHit=function() end}
local players={}
local rs={Shared={MobAnimations=animations,MobCombatConfig={Bushling={},Wolf={},Boar={},["Dire Bear"]={}}}}
local services={ReplicatedStorage=rs,RunService={Heartbeat=heartbeat},Players={GetPlayers=function() return players end}}
local wall=false
local env=setmetatable({
 game={GetService=function(_,name) return services[name] end}, require=function(value) return value end,
 workspace={Blockcast=function() return wall end}, os={clock=function() return now end},
 CFrame={new=cf,Angles=cf},Vector3={new=vector},
},{__index=getfenv()})
local function load(text,script)
 local fn=assert(loadstring(text)); setfenv(fn,setmetatable({script=script},{__index=env})); return fn()
end
local attacks={}
ATTACK_MODULES
local function context()
 local log={Hits={},Indicators={},Circles={}}
 local enabled=true
 local ctx={Mob={},Root={CFrame=cf()},Config={Size=vector(4,6,4)},RaycastParams={},Alive=function() return true end}
 ctx.Active=function() return enabled end
 ctx.Pause=function(t) now+=t; return enabled end
 ctx.Ground=function(value) return value end
 ctx.Indicator=function(...) table.insert(log.Indicators,{...}) end
 ctx.Hit=function(...) if enabled then table.insert(log.Hits,{...}) end end
 ctx.Circle=function(...) table.insert(log.Circles,{...}) end
 ctx.Cancel=function() enabled=false end
 ctx.Mob.SetAttribute=function() end
 return ctx,log
end
local ctx,log=context()
attacks.Melee(ctx,{Status="Poison"}); assert(#log.Hits==1 and log.Hits[1][6]=="Poison")
ctx,log=context(); attacks.Melee(ctx,{Count=2,Multiplier=1.2}); assert(#log.Hits==2 and log.Hits[1][4]==1.2)
ctx,log=context(); ctx.Cancel(); attacks.Melee(ctx,{}); assert(#log.Hits==0)
players={{Character={FindFirstChild=function() return {Position=vector(1,0,0)} end}},{Character={FindFirstChild=function() return {Position=vector(2,0,0)} end}}}
ctx,log=context(); ctx.Root.Position=vector(); attacks.Spikes(ctx)
assert(#log.Indicators==2 and #log.Hits==2 and log.Hits[1][6]=="Poison")
assert(log.Hits[1][7]==log.Hits[2][7],"Overlapping spikes must share hit deduplication")
ctx,log=context(); local start=now; attacks.TailSpin(ctx)
assert(now-start>=2.8 and #log.Hits>=19 and log.Hits[1][5]==65)
assert(log.Hits[1][7]==log.Hits[#log.Hits][7])
ctx,log=context(); attacks.Rush(ctx); assert(#log.Hits>0 and #log.Indicators==1)
ctx,log=context(); wall=true; attacks.Rush(ctx); assert(#log.Hits==0); wall=false
ctx,log=context(); attacks.GroundSlam(ctx); attacks.Roar(ctx)
assert(log.Circles[1][1]==16 and log.Circles[2][1]==24)
local definitions={}
local controller={Start=function(_,mob,definition) assert(definition.Basic.Execute and #definition.Skills>0) end}
local root={Controller=controller,Attacks=attacks}
BEHAVIOR_MODULES
assert(definitions.Bushling.Basic.Status=="Poison")
assert(definitions.Wolf.Skills[1].Name=="TailSpin" and definitions.Boar.Skills[1].Name=="Rush")
assert(#definitions["Dire Bear"].Skills==3)
for _,definition in definitions do definition:Start({}) end
print("PASS: four behavior modules, melee/poison, spikes deduplication, spin duration, rush obstacles, boss attacks and cancellation")
'''
for marker, directory, assignment, script_arg in [
    ('ATTACK_MODULES', 'Attacks', 'attacks', 'nil'),
    ('BEHAVIOR_MODULES', 'Behaviors', 'definitions', '{Parent={Parent=root}}'),
]:
    lines = []
    for path in sorted((root / 'Common/src/Modules/Mobs' / directory).glob('*.luau')):
        lines.append(f'{assignment}["{path.stem}"] = load([====[{path.read_text()}]====], {script_arg})')
    source = source.replace(marker, '\n'.join(lines))
with tempfile.TemporaryDirectory(prefix='mob-attacks-') as folder:
    path = Path(folder) / 'check.luau'
    path.write_text(source)
    raise SystemExit(subprocess.run([args.luau, str(path)]).returncode)
