local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UpgradeSystem = {}

function UpgradeSystem:UpgradeItem(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "No player data?")
		return
	end

	local Item = PlayerData.Inventory[UUID]()
	if not Item then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that item silly!")
		return
	end

	if Item.Upgrades >= Item.UpgradeCap then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "Item is already at max upgrades!")
		return
	end
end

return UpgradeSystem
