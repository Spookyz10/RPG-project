local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Mob: Types.MobInfo = {
	Level = 22,
	MaxLevel = 25,
	XP = 620,
	RespawnTime = 13,
	GlobalDrops = false,
	Data = { Stats = { Attack = 27, Defense = 7, Critical = 0, Health = 620, Speed = 10 } },
	Currencies = { Gold = 55 },
	Drops = {
		["Runic Bark"] = { Chance = 75, Amount = 1 },
		["Moonwater Pendant"] = { Chance = 5, Amount = 1 },
	},
}
return Mob
