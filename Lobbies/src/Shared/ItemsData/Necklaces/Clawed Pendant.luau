local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 5,
		Defense = 10,
		Critical = 0,
		["Critical Power"] = 0,
		Speed = 2,
		Health = 5,
	},
	Passive = "",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Necklace",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://79095020208761",
		Rarity = "Rare",
		Level = 7,
		ActionName = "Equip",
		ID = "Clawed Pendant",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

return Item
