local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 3,
		Defense = 0,
		Critical = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Necklace",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://3893367427",
		Rarity = "Uncommon",
		Level = 1,
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
