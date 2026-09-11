local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)
return {
 Apply = function(character) VFX:Status(character, "Safeguard") end,
 Stop = function(character) VFX:StopStatus(character, "Safeguard") end,
}
