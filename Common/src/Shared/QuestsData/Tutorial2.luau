local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = script.Name,
	Description = "Defeat 4 Wolves in the middle of the Grasslands.",
	Repeatable = false,
	RequiredLevel = 4,
	RequiredQuest = "Tutorial1",
	SkipIfOverleveled = false,
	Objectives = {
		{ Type = "KillMob", Target = "Wolf", Amount = 4 },
	},
	Rewards = {
		Currencies = { Gold = 80 },
		XP = 250,
	},
}

return Quest
