"""Exercise the production client VFX lifecycle with deterministic Roblox mocks."""
import argparse
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--luau', required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
source = r'''
local now, tick, live, emissions = 0, nil, 0, 0
local mt = {}
local function cf() return setmetatable({Position={}},mt) end
mt.__mul=function(a,b) return a end
local present=true
local function instance(class)
 local v={ClassName=class,Parent=true}
 function v:IsA(name) return self.ClassName==name end
 function v:GetAttribute(name) return self.Attributes and self.Attributes[name] end
 return v
end
local function model(name)
 local m=instance("Model");m.Name=name
 m.Attributes={Duration=1,SpinSpeed=0,RiseDistance=0}
 local part=instance("Part");part.ClassName="BasePart";part.Transparency=0
 local emitter=instance("ParticleEmitter");emitter.Rate=6;emitter.Attributes={EmitCount=3}
 function emitter:Emit(count) emissions+=count end
 local beam=instance("Beam");beam.Attributes={PreviewDuration=0.2}
 function m:GetDescendants() return {part,emitter,beam} end
 function m:GetScale() return 1 end
 function m:ScaleTo(s) self.Scale=s end
 function m:PivotTo(c) self.CFrame=c end
 function m:Destroy() if self.Parent then live-=1 end;self.Parent=nil end
 return m
end
local category={FindFirstChild=function(_,name)
 if not present then return nil end
 return {IsA=function() return true end,Clone=function() live+=1; return model(name) end,GetAttribute=function(_,key) if key=="Duration" then return 1 end end}
end}
local folder={FindFirstChild=function() return category end}
local resources={FindFirstChild=function() return folder end}
local rs={FindFirstChild=function() return resources end}
local run={IsClient=function() return true end,Heartbeat={Connect=function(_,fn) tick=fn end}}
local env=setmetatable({
 game={GetService=function(_,name) if name=="ReplicatedStorage" then return rs else return run end end},
 workspace={},CFrame={new=cf,Angles=cf,identity=cf()},os={clock=function() return now end},warn=function() end,
},{__index=getfenv()})
local fn=assert(loadstring(SOURCE));setfenv(fn,env);local VFX=fn()
local entity={Parent=true,Humanoid={Health=100},Root={CFrame=cf()},Attack="Rush"}
function entity:FindFirstChild(name) if name=="HumanoidRootPart" then return self.Root end end
function entity:FindFirstChildOfClass() return self.Humanoid end
function entity:GetAttribute() return self.Attack end
VFX:Status(entity,"Poison",10);assert(live==1 and emissions==3)
VFX:Status(entity,"Poison",20);assert(live==1 and emissions==3,"refresh duplicated emitters")
now=11;tick();assert(live==1,"refresh did not extend duration")
VFX:StopStatus(entity,"Poison");tick();assert(live==0)
VFX:Status(entity,"Fury");now=12;tick();assert(live==1,"indefinite Fury expired")
entity.Humanoid.Health=0;tick();assert(live==0,"death leaked status")
entity.Humanoid.Health=100
VFX:Status(entity,"Venom",2);entity.Parent=nil;tick();assert(live==0,"despawn leaked status")
entity.Parent=true
local moving=VFX:Play("Skills","Basic",cf(),{Entity=entity,Follow=true})
assert(moving.Emitters[1].LockedToPart == true,"moving M1 particles must follow their emitter")
now+=2;tick();assert(live==0)
local burst=VFX:Play("Attacks","Spikes",cf());assert(burst and live==1)
now+=2;tick();assert(live==0,"burst did not expire")
VFX:Play("Attacks","Rush",cf(),{Entity=entity,Follow=true,Attack="Rush",Duration=2});tick();assert(live==1)
entity.Attack=nil;tick();assert(live==0,"cancelled rush leaked")
present=false;assert(VFX:Play("Attacks","Missing",cf())==nil and live==0);present=true
for i=1,85 do VFX:Play("Attacks","Melee",cf()) end
assert(live==80,"burst cap failed")
now+=2;tick();assert(live==0)
print("PASS: VFX status refresh/removal/death/despawn, indefinite Fury, burst expiry, rush cancellation, missing assets and burst cap")
'''
source = source.replace('SOURCE', '[====[' + (root/'Common/src/Shared/CombatVFX.luau').read_text() + ']====]')
with tempfile.TemporaryDirectory(prefix='combat-vfx-') as folder:
    path=Path(folder)/'check.luau'
    path.write_text(source)
    raise SystemExit(subprocess.run([args.luau,str(path)]).returncode)
