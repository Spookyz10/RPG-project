local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillData = {
	Name = "Vital Jab",
	Cooldown = 10,
	Multiplier = 2,
	LevelRequirement = 3,
	Icon = "",
	Description = "A powerful jab that hits your enemy with great force decreasing their defense.",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
