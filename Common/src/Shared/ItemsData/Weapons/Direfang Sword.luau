local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		Attack = 9,
		Defense = 0,
		Critical = 0,
		["Critical Power"] = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "Maul",
	WeaponType = "Solo",
	Data = {
		SellsFor = 35,
		ItemType = "Equipment",
		SubType = "Weapon",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://3383616038",
		Rarity = "Rare",
		Level = 10,
		Description = "Carved from a dire bear's fang. Maul: every fourth damaging hit gains +4 Attack before skill and critical multipliers. Unequipping resets the combo.",
		ActionName = "Equip",
		ID = "Direfang Sword",
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
