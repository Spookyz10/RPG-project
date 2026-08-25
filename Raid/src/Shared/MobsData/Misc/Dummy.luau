local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 0,
	MaxLevel = 9999,
	XP = 0,
	RespawnTime = 0,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 0,
			Defense = 0,
			Critical = 0,
			Health = 0,
			Speed = 0,
		},
	},

	Currencies = {},
	Drops = {},
}

return Mob
