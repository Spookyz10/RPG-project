local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.dataservicetyped)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local template = {
	FirstTimeJoined = true,
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
}

return DataService({ template = template, profileStoreIndex = "PlayerData1" })
