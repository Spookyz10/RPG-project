local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 12,
		Defense = 10,
		Critical = 0,
		["Critical Power"] = 15,
		Speed = 2,
		Health = 50,
	},
	Passive = "",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Necklace",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://4739644274",
		Rarity = "Legendary",
		Level = 1,
		ActionName = "Equip",
		ID = "Cloak of Hide",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

return Item
