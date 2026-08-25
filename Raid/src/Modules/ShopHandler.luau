local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shops = require(ReplicatedStorage.Shared.Shops)
local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(script.Parent.InventoryManager)
local SkillManager = require(script.Parent.SkillManager)
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

function ShopHandler:Buy(player: Player, shopName: string, itemName: string): string
	local ShopInfo = Shops[shopName] :: Types.Shop
	if not ShopInfo then
		return "Shop not found"
	end

	local ItemInfo = ShopInfo[itemName]
	if not ItemInfo then
		return "Item not found"
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return "Invalid player data"
	end

	if ItemInfo.itemType == "Skill" then
		local UnlockedSkills = PlayerData.UnlockedSkills()
		if table.find(UnlockedSkills, itemName) then
			return "Skill already unlocked"
		end
	end

	if not ShopHandler:HasEnoughCurrency(PlayerData, ItemInfo.Cost) then
		return "Not enough currency"
	end

	for currency, amount in ItemInfo.Cost do
		PlayerData.Currencies()[currency](function(current)
			return current - amount
		end)
	end

	if ItemInfo.itemType == "Skill" then
		SkillManager:GrantSkill(player, itemName)
	else
		InventoryManager:AddItem(player, itemName, 1)
	end

	return "Successfully purchased item"
end

return ShopHandler