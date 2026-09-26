-- Run on the Studio CLIENT during Play. Uses isolated clones, never player data.
assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsClient(), "Run on Studio Client during Play")
local RS=game:GetService("ReplicatedStorage")
local VFX=require(RS.Shared.CombatVFX)
local stage=Instance.new("Folder");stage.Name="CombatPolishVerification";stage.Parent=workspace
local camera=workspace.CurrentCamera
local origin=camera.CFrame.Position+camera.CFrame.LookVector*12
local entries,rigs,report={},{},{}
local function play(group,name,options)
 local entry=assert(VFX:Play(group,name,CFrame.new(origin),options),name.." failed to play")
 table.insert(entries,entry);return entry
end
local ok,err=xpcall(function()
 local Motion=require(RS.Shared.MobAnimations)
 local m=RS.Mobs:FindFirstChild("Boar",true):Clone()
 for _,d in m:GetDescendants() do if d:IsA("BasePart") then d.Anchored=d.Name=="HumanoidRootPart";d.CanCollide=false end end
 m.Parent=stage;m:PivotTo(CFrame.new(origin));table.insert(rigs,m)
 Motion:Attach(m)
 task.wait(0.15)
 local moved=false
 for _,j in m:GetDescendants() do if j:IsA("Motor6D") and j.Transform~=CFrame.identity then moved=true end end
 assert(moved,"mob poses did not animate on client")
 local entity=rigs[1]
 VFX:Status(entity,"Poison",1);VFX:Status(entity,"Poison",1)
 local n=0;for _,m in workspace:GetChildren() do if m.Name=="Poison" and (m:GetPivot().Position-origin).Magnitude<20 then n+=1 end end
 assert(n==1,"duplicate status")
 entity:SetAttribute("Attack","Rush")
 local rush=play("Attacks","Rush",{Entity=entity,Follow=true,Attack="Rush",Duration=2})
 task.wait(0.08);entity:SetAttribute("Attack",nil);task.wait(0.08);assert(rush.Destroyed,"cancel")
 local delayed=play("Attacks","Roar")
 local pending=0;for _,l in delayed.Layers do if not l.Done then pending+=1 end end
 assert(pending>0,"missing staged emissions");task.wait(0.3)
 for _,l in delayed.Layers do assert(l.Done,"scheduled emission skipped") end
 task.wait(1);assert(delayed.Destroyed,"expiry")
 VFX:Status(entity,"Safeguard",10);entity.Humanoid.Health=0;task.wait(0.12)
 for _,j in entity:GetDescendants() do if j:IsA("Motor6D") then assert(j.Transform==CFrame.identity,"joint cleanup") end end
 local motion=play("Attacks","GroundSlam")
 local shard,initial
 for _,part in motion.Parts do if part.Motion=="Shard" then shard=part.Part;initial=shard.CFrame;break end end
 assert(shard,"missing animated debris")
 task.wait(0.12);assert(shard.CFrame~=initial,"debris did not move")
 assert(#motion.Trails>0 and #motion.Lights>0,"missing trails or impact light")
 task.wait(0.35)
 for _,l in motion.Lights do assert(not l.Light.Enabled,"light did not turn off") end
 local all={}
 for _,group in RS.Resources.CombatVFX:GetChildren() do
  for _,template in group:GetChildren() do
   if group.Name~="Statuses" then table.insert(all,play(group.Name,template.Name)) end
  end
 end
 task.wait(2.3)
 for _,entry in all do assert(entry.Destroyed,entry.Model.Name.." leaked") end
 local failures={};local emitters={}
 for _,e in RS.Resources.CombatVFX:GetDescendants() do if e:IsA("ParticleEmitter") then
  table.insert(emitters,e)
  if e.Texture:match("^rbxassetid://") then assert(e.LightEmission==1,"black-backed energy texture uses nonadditive blending")
  else assert(e.Texture:match("^rbxasset://textures/particles/"),"unverified alpha texture") end
 elseif e:IsA("BasePart") then
  assert(not e.CastShadow and not e.CanCollide and not e.CanQuery,"VFX must not cast shadows or block gameplay")
 end end
 game:GetService("ContentProvider"):PreloadAsync(emitters,function(id,status)
  if status~=Enum.AssetFetchStatus.Success then table.insert(failures,id) end
 end)
 assert(#failures==0,"Texture failures: "..table.concat(failures,","))
 table.insert(report,"PASS: all burst templates expire; animated debris; trails; light shutdown; additive blending; delayed emissions; status refresh; cancellation; death; textures")
end,debug.traceback)
for _,entry in entries do if entry.Model.Parent then entry.Model:Destroy() end end
for _,m in rigs do
 for _,id in {"Poison","Safeguard"} do VFX:StopStatus(m,id) end
end
stage:Destroy()
assert(ok,err)
return table.concat(report,"\n")
