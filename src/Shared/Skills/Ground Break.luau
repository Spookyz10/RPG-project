local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillData = {
	Name = script.Name,
	Cooldown = 3,
	Multiplier = 20,
	LevelRequirement = 5,
	Icon = "",
	Description = "Smash the ground and hit all enemies in front of you.",
	SkillType = "Attack",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
