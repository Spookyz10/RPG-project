local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 5,
	Multiplier = 1,
	LevelRequirement = 1,
	Icon = "rbxassetid://3009018652",
	Description = "Spin yourself in a circle to deal constant damage.",
	SkillType = "Attack",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level() >= Skill.LevelRequirement
end

return Skill
