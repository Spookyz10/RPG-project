local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 7,
		Defense = 0,
		Critical = 0,
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
		Icon = "rbxassetid://3500778015",
		Rarity = "Uncommon",
		Level = 10,
		Description = "It looks like it was ripped right out of a mountain and then designed into a sword",
		ActionName = "Equip",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

return Item
