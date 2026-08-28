local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 15,
	MaxLevel = 35,
	XP = 900,
	RespawnTime = 5,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 25,
			Defense = 0,
			Critical = 0,
			Health = 0,
			Speed = 0,
		},
	},

	Currencies = {
		Gold = 100,
	},

	Drops = {
		["Stone Cold Sword"] = { Chance = 35, Amount = 1 },
		["Tree of Life Circuit"] = { Chance = 10, Amount = 1 },
		["Small Health Potion"] = { Chance = 50, Amount = 1 },
	},
}

return Mob
