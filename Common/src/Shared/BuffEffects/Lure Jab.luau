local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)
return {
 Apply = function(character) VFX:Status(character, "Lure Jab") end,
 Stop = function(character) VFX:StopStatus(character, "Lure Jab") end,
}
