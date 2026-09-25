local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 1, MaxLevel = 15, XP = 80, RespawnTime = 6, GlobalDrops = false,
	Data = { Stats = { Attack = 4, Defense = 0, Critical = 0, Health = 40, Speed = 12 } },
	Currencies = { Gold = 8 },
	Drops = {
		["Dark Ivy"] = { Chance = 80, Amount = 1 },
		["Small Health Potion"] = { Chance = 10, Amount = 1 },
		["Bloom Pendant"] = { Chance = 8, Amount = 1 },
	},
}

return Mob
