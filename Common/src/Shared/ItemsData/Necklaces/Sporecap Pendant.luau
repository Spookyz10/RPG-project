local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 2,
		Defense = 1,
		Health = 25,
		Speed = 1,
		Critical = 4,
		["Critical Power"] = 15,
	},
	Passive = "FungalBloom",
	Data = {
		ID = "Sporecap Pendant",
		Name = "Sporecap Pendant",
		ItemType = "Equipment",
		SubType = "Necklace",
		Level = 16,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 90,
		ActionName = "Equip",
		Description = "Fungal Bloom: landing a critical hit primes your next damaging hit to deal 20% more damage.",
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
