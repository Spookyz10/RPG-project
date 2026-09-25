local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 0,
		Defense = 0,
		Health = 0,
		Speed = 0,
		Critical = 0,
		["Critical Power"] = 10,
	},
	Passive = "CanopyResonance",
	Data = {
		ID = "Rune of Resonance",
		Name = "Rune of Resonance",
		ItemType = "Equipment",
		SubType = "Rune",
		Level = 21,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 125,
		ActionName = "Equip",
		Description = "Canopy Resonance: damaging skills deal 15% more damage.",
	},
}

function Item:Elligable(data: Types.PlayerDataValue): boolean
	return data and data.Level() >= self.Data.Level
end

function Item:Action(uuid: string)
	Remote.SendServerEvent("EquipItem", uuid)
end

local TypedItem: Types.Equipment = Item
return TypedItem
