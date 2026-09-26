local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 9,
	Multiplier = 2,
	LevelRequirement = 11,
	Description = "Jab enemies and reduce their defense by 10 for 5 seconds, including below zero.",
	SkillType = "Support",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
