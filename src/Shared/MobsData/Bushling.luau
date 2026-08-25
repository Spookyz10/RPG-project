local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	HP = 5,
	MaxHP = 5,
	Level = 1,
	MaxLevel = 15,
	XP = 10,
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
		["Dark Ivy"] = { Chance = 15, Amount = 1 },
		["Small Health Potion"] = { Chance = 50, Amount = 1 },
	},
}

return Mob
