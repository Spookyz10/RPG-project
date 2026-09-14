local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 8, MaxLevel = 15, XP = 280, RespawnTime = 9, GlobalDrops = false,
	Data = { Stats = { Attack = 9, Defense = 3, Critical = 0, Health = 190, Speed = 15 } },
	Currencies = { Gold = 28 },
	Drops = {
		["Boar Tusk"] = { Chance = 70, Amount = 1 },
		Wilderbone = { Chance = 70, Amount = 1 },
		["Small Defense Potion"] = { Chance = 10, Amount = 1 },
		["Small Health Potion"] = { Chance = 10, Amount = 1 },
		["Ironhide Band"] = { Chance = 10, Amount = 1 },
		["Tuskguard Mantle"] = { Chance = 8, Amount = 1 },
	},
}

return Mob
