local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 2,
		Defense = 5,
		Critical = 0,
		["Critical Power"] = 10,
		Speed = 0,
		Health = 35,
	},
	Passive = "",
	Data = {
		SellsFor = 90,
		ItemType = "Equipment",
		SubType = "Armor",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://118565789966269",
		Rarity = "Legendary",
		Level = 12,
		ActionName = "Equip",
		ID = "Cloak of Hide",
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
