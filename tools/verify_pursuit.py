import argparse
from pathlib import Path
import subprocess
import tempfile
p = argparse.ArgumentParser()
p.add_argument('--luau', required=True)
args = p.parse_args()
source = Path('Common/src/Modules/Mobs/Pursuit.luau').read_text()
harness = r"""
local mt = {}
local function vec(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},mt) end
mt.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
mt.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
mt.__unm=function(a) return vec(-a.X,-a.Y,-a.Z) end
mt.__mul=function(a,b) if type(b)=="number" then return vec(a.X*b,a.Y*b,a.Z*b) end return vec(a.X*b.X,a.Y*b.Y,a.Z*b.Z) end
mt.__index=function(a,k)
 local length=math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z)
 if k=="Magnitude" then return length end
 if k=="Unit" then return vec(a.X/length,a.Y/length,a.Z/length) end
end
local Vector3={new=vec,zero=vec()}
local Pursuit=(function()
SOURCE
end)()
local root={Size=vec(4,6,4),Position=vec(0,0,20),CFrame={LookVector=vec(0,0,-1)},AssemblyLinearVelocity=vec(7,-2,9)}
local hum={Move=function() end,MoveTo=function(self,p) self.Destination=p end}
local mob={FindFirstChild=function() return root end,FindFirstChildOfClass=function() return hum end,GetExtentsSize=function() return vec(4,6,4) end}
local target={Position=vec(),Size=vec(2,2,1)}
local pursuit=Pursuit.new(mob,{Range=3,Speed=16})
assert(not pursuit:Update(target))
assert(hum.Destination.Z==4 and hum.WalkSpeed==16)
root.Position=vec(0,0,4)
assert(pursuit:Update(target) and hum.WalkSpeed==0)
assert(root.AssemblyLinearVelocity.X==0 and root.AssemblyLinearVelocity.Z==0 and root.AssemblyLinearVelocity.Y==-2)
root.Position=vec(0,0,4.4)
assert(pursuit:Update(target),"hysteresis prevents jitter")
root.Position=vec(0,0,5)
assert(not pursuit:Update(target) and hum.WalkSpeed<16)
root.Position=vec(0,0,1)
assert(pursuit:Update(target) and pursuit.TooClose and hum.WalkSpeed==0)
root.Position=vec()
assert(pursuit:Update(target) and hum.WalkSpeed==0,"coincident roots must remain attackable without NaN")
pursuit.Radius=8
root.Position=vec(0,0,20)
pursuit:Update(target)
assert(hum.Destination.Z==10 and pursuit.MeleeReach==10.5)
print("PASS: chase destination, body clearance, braking, hysteresis, retreat, coincident roots and boss reach")
""".replace('SOURCE',source)
with tempfile.TemporaryDirectory() as folder:
 path=Path(folder)/'pursuit.luau'
 path.write_text(harness)
 raise SystemExit(subprocess.run([args.luau,str(path)]).returncode)
