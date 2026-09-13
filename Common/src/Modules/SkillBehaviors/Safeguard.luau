local RS = game:GetService("ReplicatedStorage")
local StatusEffects = require(game:GetService("ServerStorage").Modules.StatusEffectManager)
return { Execute = function(_, caster, definition)
 local character = caster.Character
 local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 if not character or not humanoid or humanoid.Health <= 0 then return nil end
 StatusEffects:Apply(character, "Safeguard", {Source = character})
 return nil
end }
