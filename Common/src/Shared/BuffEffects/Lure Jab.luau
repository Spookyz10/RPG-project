local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)

return {
	Apply = function(character, duration)
		VFX:Status(character, "Lure Jab", duration)
	end,
	Stop = function(character)
		VFX:StopStatus(character, "Lure Jab")
	end,
}
