local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 5,
		Defense = 1,
		Critical = 1,
		Speed = 0,
		Health = 0,
	},
	Passive = "",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Ring",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://3893365534",
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
