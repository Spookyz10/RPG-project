local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 8,
	Multiplier = 1,
	LevelRequirement = 20,
	Icon = "rbxassetid://3009037877",
	Description = "Jab the enemy to weaken their defense temporarily.",
	SkillType = "Support",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
