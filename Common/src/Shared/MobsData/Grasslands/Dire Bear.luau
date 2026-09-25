local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 12,
	MaxLevel = 15,
	XP = 900,
	RespawnTime = 30,
	GlobalDrops = false,
	Data = { Stats = { Attack = 24, Defense = 5, Critical = 0, Health = 2400, Speed = 12 } },
	Currencies = { Gold = 300 },
	Drops = {
		["Dire Claw"] = { Chance = 100, Amount = 2 },
		Wilderbone = { Chance = 100, Amount = 4 },
		["Small Health Potion"] = { Chance = 100, Amount = 2 },
		["Small Attack Potion"] = { Chance = 50, Amount = 1 },
		["Small Defense Potion"] = { Chance = 50, Amount = 1 },
		["Small Critical Potion"] = { Chance = 40, Amount = 1 },
		["Direfang Sword"] = { Chance = 40, Amount = 1 },
		["Talisman of the Wild"] = { Chance = 25, Amount = 1 },
		["Clawed Pendant"] = { Chance = 20, Amount = 1 },
		["Cloak of Hide"] = { Chance = 15, Amount = 1 },
		["Crown of the Hunt"] = { Chance = 8, Amount = 1 },
	},
}

return Mob
