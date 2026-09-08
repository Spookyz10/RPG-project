local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local getCappedInfo = require(ReplicatedStorage.Shared.getCappedInfo)
local Item: Types.Consumable = {
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

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= 1
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

function Item:Use(Data: Types.PlayerData)
	if Data.ExtraStats.Attack() <= getCappedInfo.Attack then
		local newAttack = math.min(Data.ExtraStats.Attack() + Item.Amount, getCappedInfo.Attack)
		Data.ExtraStats.Attack = newAttack
	end
end

return Item
