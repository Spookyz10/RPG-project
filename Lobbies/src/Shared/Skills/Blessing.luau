local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillDefinition = {
	Name = script.Name,
	Cooldown = 13,
	Multiplier = 1,
	LevelRequirement = 10,
	Icon = "rbxassetid://5611282549",
	Description = "Heal 25% of your health.",
	SkillType = "Support",
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= Skill.LevelRequirement
end

return Skill
