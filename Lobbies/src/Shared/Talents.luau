local Talents = {
	["Strenght 1"] = {
		Rarity = "Rare",
		Chance = 80,
		Buffs = {
			Attack = 5,
		},
	},
	["Strenght 2"] = {
		Rarity = "Rare",
		Chance = 50,
		Buffs = {
			Attack = 10,
		},
	},
	["Strenght 3"] = {
		Rarity = "Legendary",
		Chance = 20,
		Buffs = {
			Attack = 15,
		},
	},
	["Striker 1"] = {
		Rarity = "Rare",
		Chance = 80,
		Buffs = {
			["Critical Chance"] = 5,
		},
	},
	["Striker 2"] = {
		Rarity = "Rare",
		Chance = 50,
		Buffs = {
			["Critical Chance"] = 10,
		},
	},
	["Striker 3"] = {
		Chance = 20,
		Rarity = "Legendary",
		Buffs = {
			["Critical Chance"] = 15,
		},
	},
	["Fatal 1"] = {
		Rarity = "Rare",
		Chance = 80,
		Buffs = {
			["Critical Power"] = 5,
		},
	},
	["Fatal 2"] = {
		Rarity = "Rare",
		Chance = 50,
		Buffs = {
			["Critical Power"] = 10,
		},
	},
	["Fatal 3"] = {
		Rarity = "Legendary",
		Chance = 20,
		Buffs = {
			["Critical Power"] = 15,
		},
	},
	["Vital"] = {
		Rarity = "Rare",
		Chance = 20,
		Buffs = {
			["Regeneration"] = 10,
		},
	},
	["Hearty"] = {
		Rarity = "Legendary",
		Chance = 20,
		Buffs = {
			["Health"] = 15,
		},
	},
	["Medic"] = {
		Rarity = "Godly",
		Chance = 5,
	},
	["Tanky"] = {
		Rarity = "Godly",
		Chance = 5,
		Buffs = {
			["Defense"] = 5,
		},
	},
	["Midas"] = {
		Rarity = "Godly",
		Chance = 5,
		Buffs = {
			["Gold"] = 50,
		},
	},
	["Smarty"] = {
		Rarity = "Godly",
		Chance = 5,
		Buffs = {
			["XP"] = 50,
		},
	},
	["Lightspeed"] = {
		Rarity = "Godly",
		Chance = 5,
		Buffs = {
			["Speed"] = 17,
		},
	},
	["Vampiric"] = {
		Rarity = "Godly",
		Chance = 5,
	},
	["Mystic"] = {
		Rarity = "Ascendant",
		Chance = 1,
		Buffs = {
			["Attack"] = 30,
			["Critical"] = 10,
		},
	},
	["Gilded"] = {
		Rarity = "Ascendant",
		Chance = 0.9,
	},
	["Dual Edge"] = {
		Rarity = "Ascendant",
		Chance = 0.5,
		Buffs = {
			["Attack"] = 100,
			["Defense"] = -250,
		},
	},
	["Universal"] = {
		Rarity = "Ascendant",
		Chance = 0.5,
		Buffs = {
			Health = 10,
			Attack = 50,
			["Critical Power"] = 20,
			Speed = 10,
			Cooldown = -10,
		},
	},
	["Void"] = {
		Rarity = "Ultimate",
		Chance = 0.1,
		Buffs = {
			Attack = 200,
			Health = 50,
			Critical = 5,
			Cooldown = -15,
		},
	},
}

return Talents
