local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 11,
		Defense = 0,
		Critical = 0,
		["Critical Power"] = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "Fury",
	WeaponType = "Dual",
	Data = {
		SellsFor = 55,
		ItemType = "Equipment",
		SubType = "Weapon",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://72133115431856",
		Rarity = "Rare",
		Level = 8,
		Description = "Fury: gain a charge every 15s while equipped (max 2). A damaging hit consumes one: guaranteed critical hit and +150% Critical Power.",
		ActionName = "Equip",
		ID = "Fang Dagger",
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
