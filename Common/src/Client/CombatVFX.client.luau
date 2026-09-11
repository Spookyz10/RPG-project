-- Replicated state restores status visuals for late joiners and streamed-in characters.
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VFX = require(RS.Shared.CombatVFX)
CollectionService:GetInstanceRemovedSignal("CombatVFXStatus"):Connect(function(entity)
 for _, id in VFX.StatusNames do VFX:StopStatus(entity, id) end
end)
-- The gallery belongs to Edit Mode; only template clones appear during gameplay.
local function hideGallery(child)
 if child.Name == "RPGVFXLab" and child:GetAttribute("Generator") == "BootlegVFXLab" then child:Destroy() end
end
for _, child in workspace:GetChildren() do hideGallery(child) end
workspace.ChildAdded:Connect(hideGallery)
while task.wait(0.25) do
 for _, entity in CollectionService:GetTagged("CombatVFXStatus") do
  if not entity:IsA("Model") or not entity:IsDescendantOf(workspace) then continue end
  for key, id in VFX.StatusNames do
   local expiry = entity:GetAttribute("VFX_" .. key)
   if typeof(expiry) == "number" and (expiry == -1 or expiry > workspace:GetServerTimeNow()) then
    local duration
    if expiry ~= -1 then duration = expiry - workspace:GetServerTimeNow() end
    VFX:Status(entity, id, duration)
   else VFX:StopStatus(entity, id) end
  end
 end
end
