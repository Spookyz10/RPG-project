local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 22,
	Multiplier = 1,
	LevelRequirement = 18,
	Description = "Restore 5% maximum health each second for 6 seconds to yourself and allies within 20 studs. Recasts refresh instead of stacking.",
	SkillType = "Support",
}
function Skill:Elligable(data): boolean
	return data.Level >= self.LevelRequirement
end
return Skill
