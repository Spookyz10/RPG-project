local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Mob: Types.MobInfo = {
	Level = 16,
	MaxLevel = 25,
	XP = 340,
	RespawnTime = 10,
	GlobalDrops = false,
	Data = { Stats = { Attack = 17, Defense = 3, Critical = 0, Health = 280, Speed = 11 } },
	Currencies = { Gold = 32 },
	Drops = {
		["Spore Silk"] = { Chance = 85, Amount = 1 },
		["Small Health Potion"] = { Chance = 8, Amount = 1 },
		["Sporecap Pendant"] = { Chance = 5, Amount = 1 },
	},
}
return Mob
