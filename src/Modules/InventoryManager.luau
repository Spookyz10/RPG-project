local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server

local InventoryManager = {}

function InventoryManager:AddItem(Player: Player, ItemName: string, Amount: number)
	local PlayerData = Data.Service:waitForData(Player)
	local ItemInfo = ItemsData[ItemName]

	if not PlayerData or not ItemInfo then
		return
	end

	local UUID = Functions:GenUUID()

	local NewItem: Types.ItemData = {
		Name = ItemName,
		Amount = Amount,
		Enchants = {},
	}

	PlayerData.Inventory[UUID](NewItem)
end

return InventoryManager
