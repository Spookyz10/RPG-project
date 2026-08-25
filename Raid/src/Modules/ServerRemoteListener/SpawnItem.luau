local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)

local ALLOWED_USER_ID = 531376199

local Remote = {}

function Remote:Activate(player: Player, itemName: string)
	if player.UserId ~= ALLOWED_USER_ID then
		return
	end

	if typeof(itemName) ~= "string" then
		return
	end

	if not ItemsData[itemName] then
		return
	end

	InventoryManager:AddItem(player, itemName, 1)
end

return Remote
