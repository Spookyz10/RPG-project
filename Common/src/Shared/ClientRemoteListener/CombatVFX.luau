local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)
local Remote = {}
function Remote:Activate(group, name, cf, entity, duration, follow, attack)
 if typeof(cf) ~= "CFrame" then return end
 VFX:Play(group, name, cf, {Entity = entity, Duration = duration, Follow = follow, Attack = attack})
end
return Remote
