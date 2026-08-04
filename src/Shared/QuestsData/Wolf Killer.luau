local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = script.Name,
	Description = "The village needs help keeping the wolf population down. Kill 5 Wolves.",
	Repeatable = true,
	Cooldown = 10,
	RequiredLevel = 1,
	RequiredQuest = nil,
	SkipIfOverleveled = false,
	Objectives = {
		{ Type = "KillMob", Target = "Wolf", Amount = 5 },
	},
	Rewards = {
		Currencies = { Gold = 40, VillagePoints = 20 },
		XP = 50,
	},
}

return Quest
