local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = "The Wounded Knight's Request",
	Description = "Defeat the Dire Bear inside the cave beside the Weakened Knight.",
	Repeatable = true,
	Cooldown = 30,
	RequiredLevel = 12,
	MaxLevel = 15,
	RequiredQuest = nil,
	SkipIfOverleveled = false,
	Objectives = {
		{ Type = "KillMob", Target = "Dire Bear", Amount = 1 },
	},
	Rewards = {
		Currencies = { Gold = 250 },
		XP = 800,
	},
}

return Quest
