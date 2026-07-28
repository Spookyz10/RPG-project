local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	HP = math.huge,
	MaxHP = math.huge,
	Level = 0,
	MaxLevel = 9999,
	XP = 0,
	RespawnTime = 0,
	GlobalDrops = false,

	Data = {
		Stats = {
			Attack = 0,
			Defense = 0,
			CriticalChance = 0,
			CriticalPower = 0,
			Health = 0,
			Luck = 0,
			Speed = 0,
		},
	},

	Currencies = {},
	Drops = {},
}

return Mob