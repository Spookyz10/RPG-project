local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob = {}

Mob["Normal"] = {
	Level = 22,
	MaxLevel = 50,
	XP = 850,
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
		Gold = 40,
	},

	Drops = {},
} :: Types.MobInfo

Mob["Hardcore"] = {
	Level = 22,
	MaxLevel = 50,
	XP = 850,
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
		Gold = 40,
	},

	Drops = {},
} :: Types.MobInfo

local Difficulty = ReplicatedStorage:FindFirstChild("Difficulty")
	and ReplicatedStorage:FindFirstChild("Difficulty").Value

return Difficulty and Mob[Difficulty] or Mob["Normal"]
