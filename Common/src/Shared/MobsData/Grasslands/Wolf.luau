local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 4, MaxLevel = 15, XP = 160, RespawnTime = 8, GlobalDrops = false,
	Data = { Stats = { Attack = 14, Defense = 1, Critical = 0, Health = 105, Speed = 18 } },
	Currencies = { Gold = 16 },
	Drops = {
		["Wolf's Fang"] = { Chance = 85, Amount = 1 },
		["Small Attack Potion"] = { Chance = 10, Amount = 1 },
		["Small Critical Potion"] = { Chance = 8, Amount = 1 },
		["Small Speed Potion"] = { Chance = 5, Amount = 1 },
		["Bloodfang Ring"] = { Chance = 7, Amount = 1 },
	},
}

return Mob
