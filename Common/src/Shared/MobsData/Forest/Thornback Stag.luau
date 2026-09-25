local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Mob: Types.MobInfo = {
	Level = 19,
	MaxLevel = 25,
	XP = 460,
	RespawnTime = 11,
	GlobalDrops = false,
	Data = { Stats = { Attack = 22, Defense = 4, Critical = 0, Health = 410, Speed = 18 } },
	Currencies = { Gold = 42 },
	Drops = {
		["Thorn Antler"] = { Chance = 80, Amount = 1 },
		["Small Speed Potion"] = { Chance = 8, Amount = 1 },
		["Bramble Loop"] = { Chance = 6, Amount = 1 },
	},
}
return Mob
