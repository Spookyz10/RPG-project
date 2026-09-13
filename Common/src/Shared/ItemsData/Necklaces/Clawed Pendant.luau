local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 4,
		Defense = 4,
		Critical = 0,
		["Critical Power"] = 0,
		Speed = 1,
		Health = 20,
	},
	Passive = "",
	Data = {
		SellsFor = 70,
		ItemType = "Equipment",
		SubType = "Necklace",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://79095020208761",
		Rarity = "Rare",
		Level = 12,
		ActionName = "Equip",
		ID = "Clawed Pendant",
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
