local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Mob: Types.MobInfo = {
	Level = 25,
	MaxLevel = 25,
	XP = 3200,
	RespawnTime = 120,
	GlobalDrops = false,
	Data = { Stats = { Attack = 38, Defense = 9, Critical = 0, Health = 6500, Speed = 9 } },
	Currencies = { Gold = 400 },
	Drops = {
		["Elder Heartwood"] = { Chance = 100, Amount = 3 },
		["Heart of the Grove"] = { Chance = 12, Amount = 1 },
	},
}
return Mob
