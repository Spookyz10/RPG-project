local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 0,
		Defense = 0,
		Critical = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "",
	EffectOverrides = {
		LureJab = { Value = 2.25, HealPercent = 0.05 },
	},
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Rune",
		Name = script.Name,
		Stackable = false,
		Icon = "",
		Rarity = "Rare",
		Level = 1,
		Description = "Empowers Lure Jab, making it deal far more bonus damage and heal you on hit.",
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
