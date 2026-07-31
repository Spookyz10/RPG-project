local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 5,
		Defense = 10,
		CriticalChance = 0,
		CriticalPower = 0,
		Luck = 0,
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
		Icon = "rbxassetid://85402159226223",
		Rarity = "Legendary",
		Level = 1,
		Description = "A pendant.",
		ActionName = "Equip",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= 1
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

return Item
