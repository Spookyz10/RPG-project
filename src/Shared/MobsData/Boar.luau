local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	HP = 100,
	MaxHP = 100,
	Level = 1,
	MaxLevel = 15,
	XP = 10,
	RespawnTime = 10,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 10,
			Defense = 1,
			CriticalChance = 0,
			CriticalPower = 0,
			Health = 10,
			Luck = 0,
			Speed = 0,
		},
	},

	Currencies = {
		Gold = 10,
		VillagePoints = 10,
	},

	Drops = {
		["Talisman of the Wild"] = { Chance = 8, Amount = 1 },
		["Wilderbone "] = { Chance = 15, Amount = 1 },
		["Small Defense Potion"] = { Chance = 50, Amount = 1 },
	},
}

return Mob
