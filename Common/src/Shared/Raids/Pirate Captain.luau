local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Raid: Types.RaidInfo = {
	Name = "Pirate Captain",
	RequiredLevel = 15,
	Image = "4553485683",
	Category = "Standard",
	Difficulties = { "Normal", "Hardcore" },
	Drops = {
		Normal = {
			["Small Health Potion"] = 100,
			["Small Attack Potion"] = 45,
			["Small Critical Potion"] = 30,
			["Small Speed Potion"] = 12,
			["Small Defense Potion"] = 40,
			["Rune of the Silencer"] = 5,
		},
		Hardcore = {
			["Small Health Potion"] = 100,
			["Small Attack Potion"] = 70,
			["Small Critical Potion"] = 50,
			["Small Speed Potion"] = 25,
			["Small Defense Potion"] = 65,
			["Rune of the Silencer"] = 12,
		},
	},
} :: Types.RaidInfo

return Raid
