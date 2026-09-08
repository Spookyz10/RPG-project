local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Raid: Types.RaidInfo = {
	Name = "Pirate Captain",
	RequiredLevel = 25,
	Image = "4553485683",
	Category = "Standard",
	Difficulties = { "Normal", "Hardcore" },
	Drops = {
		Normal = {
			["Pirate Scmitar"] = 15,
			["Small Health Potion"] = 50,
			["Small Attack Potion"] = 50,
			["Small Speed Potion"] = 10,
			["Small Defense Potion"] = 15,
		},
		Hardcore = {
			["Pirate Scmitar"] = 30,
			["Small Health Potion"] = 50,
			["Small Attack Potion"] = 50,
			["Small Speed Potion"] = 10,
			["Small Defense Potion"] = 15,
			["Pirate Coat"] = 10,
		},
	},
} :: Types.RaidInfo

return Raid
