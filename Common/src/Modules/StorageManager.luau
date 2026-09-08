local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server

local StorageManager = {}

local function MoveEntry(
	Player: Player,
	FromKey: string,
	ToKey: string,
	FromSpaceKey: string,
	ToSpaceKey: string,
	ToMaxKey: string,
	UUID: string,
	Amount: number?
): string
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return "Invalid player data"
	end

	local SourceEntry = PlayerData[FromKey][UUID]()
	if not SourceEntry then
		RemoteManager.SendClientEvent("Notification", { Player = Player }, "You don't have that item silly!")
		return "Item not found"
	end

	if SourceEntry.Equipped then
		RemoteManager.SendClientEvent("Notification", { Player = Player }, "Unequip the item first")
		return "Item equipped"
	end

	local ItemInfo = Functions:GetItemInfo(SourceEntry) :: Types.Item
	if not ItemInfo then
		return "Invalid item info"
	end

	if not SourceEntry.ID or SourceEntry.ID == "" then
		(PlayerData[FromKey] :: any)[UUID].ID(ItemInfo.Data.ID)
		SourceEntry = table.clone(SourceEntry)
		SourceEntry.ID = ItemInfo.Data.ID
	end

	local ToMove = math.clamp(math.floor(Amount or SourceEntry.Amount), 1, SourceEntry.Amount)
	local Remaining = ToMove

	if ItemInfo.Data.Stackable then
		local TargetContainer = PlayerData[ToKey]()
		local Cap = ItemInfo.Data.Cap

		for key, itemData in TargetContainer do
			if Remaining <= 0 then
				break
			end

			if itemData.ID ~= SourceEntry.ID then
				continue
			end

			local SpaceInStack = Cap - itemData.Amount
			if SpaceInStack > 0 then
				local ToAdd = math.min(SpaceInStack, Remaining)
				PlayerData[ToKey][key].Amount(itemData.Amount + ToAdd)
				Remaining -= ToAdd
			end
		end
	end

	while Remaining > 0 do
		if PlayerData[ToSpaceKey]() >= PlayerData[ToMaxKey]() then
			RemoteManager.SendClientEvent("Notification", { Player = Player }, "No space available")
			break
		end

		local NewUUID = Functions:GenUUID()
		local ToAdd = ItemInfo.Data.Stackable and math.min(ItemInfo.Data.Cap, Remaining) or 1

		local NewItem: Types.ItemData = {
			Name = SourceEntry.Name,
			ID = SourceEntry.ID,
			Amount = ToAdd,
			Enchants = SourceEntry.Enchants or {},
			Upgrades = SourceEntry.Upgrades or 0,
			UpgradeCap = SourceEntry.UpgradeCap or math.random(3, 10),
		}

		PlayerData[ToKey][NewUUID](NewItem)
		PlayerData[ToSpaceKey](PlayerData[ToSpaceKey]() + 1)

		Remaining -= ToAdd
	end

	local Moved = ToMove - Remaining
	if Moved <= 0 then
		return "Nothing moved"
	end

	local ResultingAmount = SourceEntry.Amount - Moved
	if ResultingAmount <= 0 then
		PlayerData[FromKey][UUID](nil)
		PlayerData[FromSpaceKey](PlayerData[FromSpaceKey]() - 1)
	else
		PlayerData[FromKey][UUID].Amount(ResultingAmount)
	end

	return "Successfully moved item"
end

function StorageManager:ToStorage(Player: Player, UUID: string, Amount: number?): string
	return MoveEntry(
		Player,
		"Inventory",
		"Storage",
		"CurrentInventorySpace",
		"CurrentStorageSpace",
		"MaxStorageSpace",
		UUID,
		Amount
	)
end

function StorageManager:ToInventory(Player: Player, UUID: string, Amount: number?): string
	return MoveEntry(
		Player,
		"Storage",
		"Inventory",
		"CurrentStorageSpace",
		"CurrentInventorySpace",
		"MaxInventorySpace",
		UUID,
		Amount
	)
end

return StorageManager
