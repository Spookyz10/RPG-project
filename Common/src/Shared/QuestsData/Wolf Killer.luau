local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = script.Name,
	Description = "The village needs help keeping the wolf population down. Kill 5 Wolves.",
	Repeatable = true,
	Cooldown = 60,
	RequiredLevel = 4,
	RequiredQuest = nil,
	SkipIfOverleveled = false,
	MaxLevel = 15,
	Objectives = {
		{ Type = "KillMob", Target = "Wolf", Amount = 5 },
	},
	Rewards = {
		Currencies = { Gold = 100 },
		XP = 300,
	},
}

return Quest
