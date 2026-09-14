local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shops = require(ReplicatedStorage.Shared.Shops)
local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(script.Parent.InventoryManager)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local ShopHandler = {}

function ShopHandler:HasEnoughCurrency(PlayerData: Types.PlayerData, Cost: { [string]: number }): boolean
	local Currencies = PlayerData.Currencies()

	for currency, amount in Cost do
		if (Currencies[currency] or 0) < amount then
			return false
		end
	end

	return true
end

function ShopHandler:Buy(player: Player, shopName: string, itemName: string, amount: number?): string
	if typeof(shopName) ~= "string" or typeof(itemName) ~= "string" then return "Invalid purchase" end
	local ShopInfo = Shops[shopName] :: Types.Shop
	if not ShopInfo then
		return "Shop not found"
	end

	local ItemInfo = ShopInfo[itemName]
	if not ItemInfo then
		return "Item not found"
	end
	local item = ItemsData[itemName]
	if ItemInfo.itemType ~= "Consumable" or not item or item.Kind ~= "Consumable" then return "Item not available" end
	amount = amount or 1
	if typeof(amount) ~= "number" or amount ~= amount or amount == math.huge or amount == -math.huge or amount % 1 ~= 0 then
		return "Invalid quantity"
	end
	local maxPurchase = ItemInfo.MaxPurchase or 1
	if amount < 1 or amount > maxPurchase or (not item.Data.Stackable and amount ~= 1) then return "Choose between 1 and " .. maxPurchase end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return "Invalid player data"
	end

	local totalCost = {}
	for currency, cost in ItemInfo.Cost do totalCost[currency] = cost * amount end
	if not ShopHandler:HasEnoughCurrency(PlayerData, totalCost) then
		return "Not enough currency"
	end

	local result, _, added = InventoryManager:AddItem(player, itemName, amount)
	if added <= 0 then return result end
	for currency, cost in ItemInfo.Cost do
		local charged = cost * added
		PlayerData.Currencies[currency](function(current) return current - charged end)
	end
	if added < amount then return "Purchased " .. added .. " / " .. amount .. " (inventory full)" end
	return "Purchased " .. added .. " " .. itemName .. (added == 1 and "" or "s")
end

return ShopHandler
