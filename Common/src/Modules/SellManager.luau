local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(script.Parent.InventoryManager)
local RewardManager = require(script.Parent.RewardManager)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SellManager = {}

local function IsInUseAsVanity(PlayerData: Types.PlayerData, UUID: string): boolean
	for _, VanityUUID in PlayerData.Vanity() do
		if VanityUUID == UUID then
			return true
		end
	end

	return false
end

function SellManager:SellItems(player: Player, sellList: { [string]: number })
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if typeof(sellList) ~= "table" then
		return
	end

	local TotalValue = 0

	for UUID, amount in sellList do
		if typeof(UUID) ~= "string" or typeof(amount) ~= "number" then
			continue
		end

		local ItemEntry = PlayerData.Inventory[UUID]()
		if not ItemEntry then
			continue
		end

		if ItemEntry.Equipped then
			continue
		end

		if IsInUseAsVanity(PlayerData, UUID) then
			continue
		end

		local ItemInfo = Functions:GetItemInfo(ItemEntry) :: Types.Item
		if not ItemInfo then
			continue
		end

		if not ItemEntry.ID or ItemEntry.ID == "" then
			PlayerData.Inventory[UUID].ID(ItemInfo.Data.ID)
		end

		local SellAmount = math.clamp(math.floor(amount), 1, ItemEntry.Amount)

		local RemoveResult = InventoryManager:RemoveItemByUUID(player, UUID, SellAmount)
		if RemoveResult == "Successfully deleted item" then
			TotalValue += (ItemInfo.Data.SellsFor or 0) * SellAmount
		end
	end

	if TotalValue > 0 then
		RewardManager:AddCurrency(player, "Gold", TotalValue)
	end
end

return SellManager
