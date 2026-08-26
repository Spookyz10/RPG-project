local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 3,
		Defense = 0,
		Critical = 0,
		Speed = 0,
		Health = 0,
	},
	Passive = "",
	WeaponType = "Solo",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Weapon",
		Name = script.Name,
		Stackable = false,
		Icon = "rbxassetid://3383616038",
		Rarity = "Uncommon",
		Level = 1,
		Description = "Probably came from a Knight who got ate by the bear",
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
