-- EDIT MODE: select one generated Model in Resources or the lab, then paste this file.
-- Animates a temporary clone. The saved template is never modified.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first.")
local selected = game:GetService("Selection"):Get()[1]
assert(selected and selected:IsA("Model") and selected.PrimaryPart and selected:GetAttribute("Duration"), "Select one generated VFX Model.")
local model = selected:Clone()
local cf = selected:GetPivot()
if not selected:IsDescendantOf(workspace) then
 cf = CFrame.new(workspace.CurrentCamera.Focus.Position)
end
local duration = math.min(selected:GetAttribute("Duration") or 1, 3)
local rise = model:GetAttribute("RiseDistance") or 0
local spin = model:GetAttribute("SpinSpeed") or 0
local expand = model:GetAttribute("ExpandFrom")
local scale = model:GetScale()
local parts = {}
model.Name = "VFXPreview"
if expand then model:ScaleTo(scale * expand) end
model:PivotTo(cf * CFrame.new(0, -rise, 0))
model.Parent = workspace
for _, v in model:GetDescendants() do
 if v:IsA("ParticleEmitter") then v:Emit(v:GetAttribute("EmitCount") or 1); v.Enabled = v.Rate > 0
 elseif v:IsA("Beam") then v.Enabled = true
 elseif v:IsA("BasePart") then table.insert(parts, {v, v.Transparency}) end
end
task.spawn(function()
 local start = os.clock()
 while model.Parent and os.clock() - start < duration do
  local elapsed = os.clock() - start
  model:PivotTo(cf * CFrame.new(0, -rise * (1 - math.min(1, elapsed / 0.16)) ^ 2, 0) * CFrame.Angles(0, spin * elapsed, 0))
  if expand then model:ScaleTo(scale * (expand + (1 - expand) * math.min(1, elapsed / (duration * 0.7)))) end
  local fade = math.clamp(1 - (duration - elapsed) / 0.25, 0, 1)
  for _, pair in parts do pair[1].Transparency = pair[2] + (1 - pair[2]) * fade end
  task.wait()
 end
 model:Destroy()
end)
