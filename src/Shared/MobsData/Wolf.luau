local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	HP = 15,
	MaxHP = 15,
	Level = 1,
	MaxLevel = 15,
	XP = 70,
	RespawnTime = 10,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 10,
			Defense = 0,
			CriticalChance = 0,
			Health = 10,
			Speed = 0,
		},
	},

	Currencies = {
		Gold = 10,
		VillagePoints = 10,
	},

	Drops = {
		["Wolf's Fang"] = { Chance = 15, Amount = 1 },
		["Small Attack Potion"] = { Chance = 30, Amount = 1 },
	},
}

return Mob
