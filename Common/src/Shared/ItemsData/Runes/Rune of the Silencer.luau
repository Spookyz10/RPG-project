local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 0,
		Defense = 0,
		Critical = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "",
	EffectOverrides = {
		LureJab = { HealPercent = 0.05 },
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
		Description = "Lure Jab also heals you for 5% of maximum health on hit. Defense reduction remains 10.",
		ActionName = "Equip",
		ID = "Rune of the Silencer",
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
