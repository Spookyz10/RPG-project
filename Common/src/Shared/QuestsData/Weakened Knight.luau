local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = "The Wounded Knight's Request",
	Description = "Defeat the Dire Bear near the cave at the end of the Village Outskirts.",
	Repeatable = false,
	RequiredLevel = 1,
	RequiredQuest = nil,
	SkipIfOverleveled = false,
	Objectives = {
		{ Type = "KillMob", Target = "Dire Bear", Amount = 1 },
	},
	Rewards = {
		Currencies = { Gold = 50 },
		XP = 40,
	},
}

return Quest
