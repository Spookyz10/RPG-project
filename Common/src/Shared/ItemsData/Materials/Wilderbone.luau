local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Material = {
	Kind = "Material",
	Data = {
		SellsFor = 10,
		ItemType = "Material",
		SubType = "Mob Material",
		Name = script.Name,
		Stackable = true,
		Cap = 25,
		Icon = "rbxassetid://140518279089737",
		Rarity = "Common",
		Level = 1,
		Description = "Used to Craft Fang Dagger.",
		ActionName = nil,
		ID = "Wilderbone",
	},
}

function Item:Elligable(PlayerData: Types.PlayerDataValue): boolean
	return PlayerData and PlayerData.Level() >= 1
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end


return Item
