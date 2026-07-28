local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.SkillData = {
	Name = "Whirlwind",
	Cooldown = 5,
	Multiplier = 10,
}

function Skill:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData.Level >= 1
end

return Skill
