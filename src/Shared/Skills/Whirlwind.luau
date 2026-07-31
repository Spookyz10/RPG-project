local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillData = {
	Name = script.Name,
	Cooldown = 5,
	Multiplier = 10,
	LevelRequirement = 1,
	Icon = "",
	Description = "Spin around and hit all enemies around you.",
	SkillType = "Attack",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
