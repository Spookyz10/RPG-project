local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillData = {
	Name = "Consecutive Slashes",
	Cooldown = 3,
	Multiplier = 3,
	LevelRequirement = 10,
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
