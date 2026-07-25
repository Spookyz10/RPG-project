local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.dataservicetyped)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local template: Types.PlayerData = {
	FirstTimeJoined = true,
	Level = 1,
	XP = 0,
	Inventory = {} :: { [string]: Types.ItemData },
	Settings = {
		Music = true,
		CameraShake = true,
	},
	Equipment = {
		Weapon = "",
		Armor = "",
		Ring = "",
		Necklace = "",
	},
	MaxInventorySpace = 100,
	CurrentInventorySpace = 0,
	Skills = {
		Q = "",
		E = "",
		R = "",
	},
	UnlockedSkills = {}, -- {"Skill1" , "Skill2"},
	Currencies = {}, -- {[Currency] = Amount}
}

return DataService({ template = template, profileStoreIndex = "PlayerData1" })
