local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = "Tutorial3",
	Description = "Craft a Fang Dagger at the blacksmith using materials from the wild.",
	Repeatable = false,
	RequiredLevel = 1,
	RequiredQuest = "Tutorial2",
	SkipIfOverleveled = false,
	Objectives = {
		{ Type = "CraftItem", Target = "Fang Dagger", Amount = 1 },
	},
	Rewards = {
		Currencies = { Gold = 75 },
		XP = 60,
	},
}

return Quest
