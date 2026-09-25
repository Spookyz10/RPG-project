local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 18,
		Defense = 0,
		Health = 0,
		Speed = 2,
		Critical = 5,
		["Critical Power"] = 15,
	},
	Passive = "Sporeburst",
	WeaponType = "Dual",
	Data = {
		ID = "Sporethorn Daggers",
		Name = "Sporethorn Daggers",
		ItemType = "Equipment",
		SubType = "Weapon",
		Level = 18,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 105,
		ActionName = "Equip",
		Description = "Sporeburst: every third damaging hit is a guaranteed critical hit with +50% Critical Power.",
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
