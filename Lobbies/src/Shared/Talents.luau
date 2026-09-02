local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Talents: { [string]: Types.TalentInfo } = {
	["No Talent"] = {
		Rarity = "Common",
		Weight = 0,
		Effects = {},
	},

	["Strength 1"] = {
		Rarity = "Rare",
		Weight = 10,
		Effects = { { Stat = "Damage", Type = "Percentage", Value = 5 } },
	},
	["Strength 2"] = {
		Rarity = "Rare",
		Weight = 7,
		Effects = { { Stat = "Damage", Type = "Percentage", Value = 10 } },
	},
	["Strength 3"] = {
		Rarity = "Legendary",
		Weight = 6,
		Effects = { { Stat = "Damage", Type = "Percentage", Value = 15 } },
	},

	["Striker 1"] = {
		Rarity = "Rare",
		Weight = 10,
		Effects = { { Stat = "Critical", Type = "Flat", Value = 5 } },
	},
	["Striker 2"] = {
		Rarity = "Rare",
		Weight = 7,
		Effects = { { Stat = "Critical", Type = "Flat", Value = 10 } },
	},
	["Striker 3"] = {
		Rarity = "Legendary",
		Weight = 6,
		Effects = { { Stat = "Critical", Type = "Flat", Value = 15 } },
	},

	["Fatal 1"] = {
		Rarity = "Rare",
		Weight = 10,
		Effects = { { Stat = "CriticalMultiplier", Type = "Percentage", Value = 5 } },
	},
	["Fatal 2"] = {
		Rarity = "Rare",
		Weight = 7,
		Effects = { { Stat = "CriticalMultiplier", Type = "Percentage", Value = 10 } },
	},
	["Fatal 3"] = {
		Rarity = "Legendary",
		Weight = 6,
		Effects = { { Stat = "CriticalMultiplier", Type = "Percentage", Value = 15 } },
	},

	["Vital"] = {
		Rarity = "Rare",
		Weight = 7,
		Effects = { { Stat = "HealthRegen", Type = "Percentage", Value = 10 } },
	},

	["Hearty"] = {
		Rarity = "Legendary",
		Weight = 6,
		Effects = { { Stat = "Health", Type = "Percentage", Value = 15 } },
	},

	["Medic"] = {
		Rarity = "Godly",
		Weight = 5,
		Unique = "Medic",
		HealsOverTime = true,
		Effects = {},
	},

	["Tanky"] = {
		Rarity = "Godly",
		Weight = 3,
		Effects = { { Stat = "IncomingDamage", Type = "Percentage", Value = -15 } },
	},

	["Midas"] = {
		Rarity = "Godly",
		Weight = 3,
		Unique = "Midas",
		Effects = { { Stat = "Gold", Type = "Percentage", Value = 50 } },
	},

	["Smarty"] = {
		Rarity = "Godly",
		Weight = 3,
		Unique = "Smarty",
		Effects = { { Stat = "XP", Type = "Percentage", Value = 50 } },
	},

	["Lightspeed"] = {
		Rarity = "Godly",
		Weight = 2,
		Effects = { { Stat = "Speed", Type = "Flat", Value = 17 } },
	},

	["Vampiric"] = {
		Rarity = "Godly",
		Weight = 1,
		Unique = "Vampiric",
		Effects = { { Stat = "Lifesteal", Type = "Percentage", Value = 0.5 } },
	},

	["Mystic"] = {
		Rarity = "Ascendant",
		Weight = 0.25,
		Unique = "Mystic",
		Effects = {
			{ Stat = "Damage", Type = "Percentage", Value = 30 },
			{ Stat = "Critical", Type = "Flat", Value = 10 },
			{ Stat = "ExecuteDamage", Type = "Percentage", Value = 20 },
		},
	},

	["Gilded"] = {
		Rarity = "Ascendant",
		Weight = 0.2,
		Unique = "Gilded",
		Effects = {},
	},

	["Dual Edge"] = {
		Rarity = "Ascendant",
		Weight = 0.1,
		Effects = {
			{ Stat = "Damage", Type = "Percentage", Value = 100 },
			{ Stat = "IncomingDamage", Type = "Percentage", Value = 250 },
		},
	},

	["Universal"] = {
		Rarity = "Ascendant",
		Weight = 0.1,
		Unique = "Universal",
		HealsOverTime = true,
		Effects = {
			{ Stat = "Health", Type = "Percentage", Value = 10 },
			{ Stat = "Damage", Type = "Percentage", Value = 50 },
			{ Stat = "CriticalMultiplier", Type = "Percentage", Value = 20 },
			{ Stat = "Speed", Type = "Flat", Value = 10 },
			{ Stat = "CooldownDuration", Type = "Percentage", Value = -10 },
		},
	},

	["Void"] = {
		Rarity = "Secret",
		Weight = 0.01,
		HealsOverTime = true,
		Effects = {
			{ Stat = "Health", Type = "Percentage", Value = 40 },
			{ Stat = "Damage", Type = "Percentage", Value = 100 },
			{ Stat = "CriticalMultiplier", Type = "Percentage", Value = 30 },
			{ Stat = "Speed", Type = "Flat", Value = 15 },
			{ Stat = "CooldownDuration", Type = "Percentage", Value = -20 },
		},
	},
}

return Talents
