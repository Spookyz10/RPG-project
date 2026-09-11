local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 15,
	MaxLevel = 15,
	XP = 1800,
	RespawnTime = 30,
	GlobalDrops = false,
	Data = { Stats = { Attack = 30, Defense = 6, Critical = 0, Health = 2400, Speed = 12 } },
	Currencies = { Gold = 250 },
	Drops = {
		["Dire Claw"] = { Chance = 100, Amount = 1 },
		["Direheart Pendant"] = { Chance = 15, Amount = 1 },
		["Crown of the Hunt"] = { Chance = 12, Amount = 1 },

		Wilderbone = { Chance = 100, Amount = 8 },
		["Direfang Sword"] = { Chance = 35, Amount = 1 },
		["Talisman of the Wild"] = { Chance = 30, Amount = 1 },
		["Clawed Pendant"] = { Chance = 30, Amount = 1 },
		["Cloak of Hide"] = { Chance = 30, Amount = 1 },
	},
}

return Mob
