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
	local Remaining = Amount

	if ItemInfo.Stackable then
		local isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "Name", ItemName)
		while isInInventory and Remaining > 0 do
			local itemData = Inventory[key]
			local SpaceInStack = ItemInfo.Cap - itemData.Amount

			if SpaceInStack > 0 then
				local ToAdd = math.min(SpaceInStack, Remaining)
				Inventory[key].Amount(itemData.Amount + ToAdd)
				Remaining -= ToAdd
			end

			if Remaining <= 0 then
				break
			end

			isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "Name", ItemName)
		end
	end

	while Remaining > 0 do
		if PlayerData.CurrentInventorySpace() >= PlayerData.MaxInventorySpace() then
			return "Inventory full"
		end

		local UUID = Functions:GenUUID()
		local ToAdd = ItemInfo.Stackable and math.min(ItemInfo.Cap, Remaining) or 1

		local NewItem: Types.ItemData = {
			Name = ItemName,
			Amount = ToAdd,
			Enchants = {},
			Upgrades = 0,
		}

		PlayerData[UUID](NewItem)
		PlayerData.CurrentInventorySpace(PlayerData.CurrentInventorySpace() + 1)

		Remaining -= ToAdd
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
	local Remaining = Amount

	local isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "Name", ItemName)
	while isInInventory and Remaining > 0 do
		local itemData = Inventory[key]
		local ToRemove = math.min(itemData.Amount, Remaining)
		local ResultingAmount = itemData.Amount - ToRemove

		if ResultingAmount <= 0 then
			Inventory[key](nil)
			PlayerData.CurrentInventorySpace(PlayerData.CurrentInventorySpace() - 1)
		else
			Inventory[key].Amount(ResultingAmount)
		end

		Remaining -= ToRemove
		isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "Name", ItemName)
	end

	if Remaining > 0 then
		return "Item not found or insufficient amount"
	end

	return "Successfully deleted item"
end

return InventoryManager
