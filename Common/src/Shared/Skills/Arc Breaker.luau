local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 12,
	Multiplier = 5,
	LevelRequirement = 25,
	Description = "Unleash a sweeping arc in front of you, striking each enemy once for 5x attack damage.",
	SkillType = "Attack",
}
function Skill:Elligable(data): boolean
	return data.Level >= self.LevelRequirement
end
return Skill
