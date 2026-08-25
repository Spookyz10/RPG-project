local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 7,
	MaxLevel = 27,
	XP = 15,
	RespawnTime = 5,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 4,
			Defense = 0,
			Critical = 0,
			Health = 0,
			Speed = 0,
		},
	},

	Currencies = {
		Gold = 110,
	},

	Drops = {},
}

return Mob
