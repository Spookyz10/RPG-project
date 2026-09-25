local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 2,
		Defense = 5,
		Health = 25,
		Speed = 0,
		Critical = 0,
		["Critical Power"] = 0,
	},
	Passive = "ArcaneGuard",
	Data = {
		ID = "Sentinel Signet",
		Name = "Sentinel Signet",
		ItemType = "Equipment",
		SubType = "Ring",
		Level = 22,
		Rarity = "Epic",
		Stackable = false,
		SellsFor = 145,
		ActionName = "Equip",
		Description = "Arcane Guard: dealing damage charges a ward; the next damaging hit received deals 20% less damage.",
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
