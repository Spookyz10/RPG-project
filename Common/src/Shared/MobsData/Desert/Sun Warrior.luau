local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 7,
	MaxLevel = 27,
	XP = 600,
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
		Gold = 50,
	},

	Drops = {
		["Sun Warrior's Blade"] = { Chance = 35, Amount = 1 },
		["Sun Pride Necklace"] = { Chance = 17, Amount = 1 },
		["Small Attack Potion"] = { Chance = 20, Amount = 1 },
	},
}

return Mob
