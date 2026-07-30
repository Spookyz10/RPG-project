local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillData = {
	Name = "Ground Break",
	Cooldown = 3,
	Multiplier = 20,
	LevelRequirement = 5,
	Icon = "",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
