local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)
return { Play = function(_, character) VFX:Skill("Arc Breaker", character) end }
