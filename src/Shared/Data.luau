local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.dataservicetyped)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local template = {
	FirstTimeJoined = true,
	Stats = {
		Attack = 0,
		Defense = 0,
		CriticalChance = 0,
		CriticalPower = 0,
	},
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
}

return DataService({ template = template, profileStoreIndex = "PlayerData1" })
