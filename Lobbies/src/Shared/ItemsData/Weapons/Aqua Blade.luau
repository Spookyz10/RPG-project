local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Kind = "Equipment",
	Stats = {
		Attack = 9,
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
		Icon = "rbxassetid://3502148014",
		Rarity = "Uncommon",
		Level = 15,
		Description = "A couple hundred of these and you can make a pool",
		ActionName = "Equip",
		ID = "Aqua Blade",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= 2
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

return Item
