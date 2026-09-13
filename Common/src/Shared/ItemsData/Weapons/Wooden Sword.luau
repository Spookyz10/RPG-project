local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 5,
		Defense = 0,
		Critical = 0,
		["Critical Power"] = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "",
	WeaponType = "Solo",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Weapon",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://3383616038",
		Rarity = "Common",
		Level = 1,
		Description = "A simple wooden sword, sturdy enough for an adventurer's first steps.",
		ActionName = "Equip",
		ID = "Wooden Sword",
	},
}

function Item:Elligable(PlayerData: Types.PlayerDataValue): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

local TypedItem: Types.Equipment = Item
return TypedItem
