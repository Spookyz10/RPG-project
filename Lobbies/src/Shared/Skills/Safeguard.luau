local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 10,
	Multiplier = 1,
	LevelRequirement = 12,
	Icon = "rbxassetid://4863970462",
	Description = "Create a bubble that negates 70% of incoming damage for 5 seconds.",
	SkillType = "Support",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
