local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 5,
		Defense = 2,
		Critical = 0,
		Speed = 0,
		Health = 10,
	},
	Passive = "",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Ring",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://123995209972282",
		Rarity = "Rare",
		Level = 9,
		ActionName = "Equip",
		ID = "Talisman of the Wild",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

return Item
