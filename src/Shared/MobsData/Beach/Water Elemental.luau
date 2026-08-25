local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 22,
	MaxLevel = 50,
	XP = 105,
	RespawnTime = 5,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 8,
			Defense = 0,
			Critical = 0,
			Health = 0,
			Speed = 0,
		},
	},

	Currencies = {
		Gold = 110,
	},

	Drops = {
		["Crabby Ring"] = { Chance = 20, Amount = 1 },
		["Aqua Blade"] = { Chance = 25, Amount = 1 },
		["Small Attack Potion"] = { Chance = 50, Amount = 1 },
		["Small Health Potion"] = { Chance = 50, Amount = 1 },
	},
}

return Mob
