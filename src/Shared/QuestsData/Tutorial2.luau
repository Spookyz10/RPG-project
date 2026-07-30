local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = "Tutorial2",
	Description = "Defeat the Bear that lurks at the edge of the Village Outskirts.",
	Repeatable = false,
	RequiredLevel = 1,
	RequiredQuest = "Tutorial1",
	SkipIfOverleveled = false,
	Objectives = {
		{ Type = "KillMob", Target = "Bear", Amount = 1 },
	},
	Rewards = {
		Currencies = { Gold = 50 },
		XP = 40,
		Recipes = { "Fang Dagger" },
	},
}

return Quest
