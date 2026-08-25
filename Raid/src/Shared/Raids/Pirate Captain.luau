local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Raid = {
	Name = "Pirate Captain",
	RequiredLevel = 25,
	Drops = {
		["Pirate Scmitar"] = 15,
		["Small Health Potion"] = 50,
		["Small Attack Potion"] = 50,
		["Small Speed Potion"] = 10,
		["Small Defense Potion"] = 15,
	},
	HCDrops = {
		["Pirate Scmitar"] = 30,
		["Small Health Potion"] = 50,
		["Small Attack Potion"] = 50,
		["Small Speed Potion"] = 10,
		["Small Defense Potion"] = 15,
		["Pirate Captain Armor"] = 10,
	},
} :: Types.RaidInfo

return Raid
