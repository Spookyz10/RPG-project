local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 1,
	MaxLevel = 15,
	XP = 500,
	RespawnTime = 5,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 15,
			Defense = 0,
			Critical = 0,
			Health = 0,
			Speed = 0,
		},
	},

	Currencies = {
		Gold = 90,
	},

	Drops = {
		["Small Health Potion"] = { Chance = 25, Amount = 1 },
		["Rusty Blade"] = { Chance = 40, Amount = 1 },
		["Emerald Trinket"] = { Chance = 15, Amount = 1 },
		["Holy Necklace"] = { Chance = 15, Amount = 1 },
	},
}

return Mob
