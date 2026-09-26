local VFX = require(game:GetService("ReplicatedStorage").Shared.CombatVFX)
return { Play = function(_, character, comboIndex) VFX:Skill("Basic", character, comboIndex) end }
