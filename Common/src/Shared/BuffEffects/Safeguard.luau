local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)

return {
	Apply = function(character, duration)
		VFX:Status(character, "Safeguard", duration)
	end,
	Stop = function(character)
		VFX:StopStatus(character, "Safeguard")
	end,
}
