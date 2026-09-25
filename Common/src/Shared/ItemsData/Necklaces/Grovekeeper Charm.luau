local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 3,
		Defense = 4,
		Health = 50,
		Speed = 1,
		Critical = 0,
		["Critical Power"] = 10,
	},
	Passive = "CycleOfLife",
	Data = {
		ID = "Grovekeeper Charm",
		Name = "Grovekeeper Charm",
		ItemType = "Equipment",
		SubType = "Necklace",
		Level = 25,
		Rarity = "Epic",
		Stackable = false,
		SellsFor = 175,
		ActionName = "Equip",
		Description = "Cycle of Life: every fourth damaging hit deals 20% more damage above half Health, or restores 7% maximum Health at or below half Health.",
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
