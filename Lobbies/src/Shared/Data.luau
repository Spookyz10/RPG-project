local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.dataservicetyped)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local template: Types.PlayerData = {
	FirstTimeJoined = true,
	Level = 1,
	XP = 0,
	Kills = 0,
	Deaths = 0,
	PlayTime = 0,
	Inventory = {} :: { [string]: Types.ItemData },
	Settings = {
		Music = true,
		CameraShake = true,
	},
	Equipment = {
		Weapon = "",
		Armor = "",
		Ring = "",
		Necklace = "",
		Aura = "",
		Rune = "",
	},
	MaxInventorySpace = 100,
	CurrentInventorySpace = 0,
	Skills = {
		Q = "",
		E = "",
		R = "",
	},
	UnlockedSkills = {}, -- {"Skill1" , "Skill2"},
	Currencies = {}, -- {[Currency] = Amount}
	UnlockedRecipes = {},
	ExtraStats = {
		Health = 0,
		Speed = 0,
		Attack = 0,
		Critical = 0,
		Defense = 0,
	},
	MobIndex = {},
	Quests = {},
	DailyQuests = {},
	CompletedQuests = {},
	LastDailyReward = 0,
	TotalDailyRewards = 0,
	DailyStreak = 0,
}

return DataService({ template = template, profileStoreIndex = "PlayersData2" })
