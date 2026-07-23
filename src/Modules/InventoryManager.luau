local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server

local InventoryManager = {}

function InventoryManager:AddItem(Player: Player, ItemName: string, Amount: number): string
	local PlayerData = Data.Service:waitForData(Player)
	local ItemInfo = ItemsData[ItemName] :: Types.ItemInfo

	if not PlayerData or not ItemInfo then
		return "Invalid player data or itemInfo", PlayerData, ItemInfo
	end

	local Inventory = PlayerData.Inventory()
	local key, isInInventory = Functions:HasKeyWithValueIntable(Inventory)
	if isInInventory and ItemInfo.Stackable then
		if key.Amount then
			Inventory[key].Amount()
		end
	else
		for _ = 1, Amount do
			local UUID = Functions:GenUUID()

			local NewItem: Types.ItemData = {
				Name = ItemName,
				Amount = Amount,
				Enchants = {},
				Upgrades = 0,
			}

			PlayerData[UUID](NewItem)
		end
	end

	return "Successfully added item"
end

function InventoryManager:RemoveItem(Player: Player, ItemName: string, Amount: number): string
	local PlayerData = Data.Service:waitForData(Player)
	local ItemInfo = ItemsData[ItemName] :: Types.ItemInfo

	if not PlayerData or not ItemInfo then
		return "Invalid player data or itemInfo", PlayerData, ItemInfo
	end

	local Inventory = PlayerData.Inventory()
	local key, isInInventory = Functions:HasKeyWithValueIntable(Inventory)
	if isInInventory and ItemInfo.Stackable then
		local ResultingAmount = Inventory[key].Amount() - Amount
		if ResultingAmount <= 0 then
			Inventory[key](nil)
		else
			Inventory[key](ResultingAmount)
		end
	else
		Inventory[key](nil)
	end

	return "Successfully deleted item"
end

return InventoryManager
