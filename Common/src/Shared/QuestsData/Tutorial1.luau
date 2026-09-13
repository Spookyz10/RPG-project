local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Quest: Types.QuestInfo = {
	Name = script.Name,
	Description = "Defeat 3 Bushlings to prove you can handle yourself.",
	Repeatable = false,
	RequiredLevel = 1,
	RequiredQuest = nil,
	SkipIfOverleveled = true,
	Objectives = {
		{ Type = "KillMob", Target = "Bushling", Amount = 3 },
	},
	Rewards = {
		Currencies = { Gold = 30 },
		XP = 100,
		Items = {
			["Small Attack Potion"] = 2,
		},
	},
}

return Quest
