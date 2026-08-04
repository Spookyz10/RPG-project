local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Data = require(ReplicatedStorage.Shared.Data).server
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UpgradeSystem = {}

local BASE_COST = 100
local START_CHANCE = 95
local END_CHANCE = 20

function UpgradeSystem:GetCost(Upgrades: number): number
	return math.floor(BASE_COST * (Upgrades + 1) * (1 + Upgrades * 0.5))
end

function UpgradeSystem:GetChance(Upgrades: number, UpgradeCap: number): number
	local Progress = Upgrades / UpgradeCap
	local Chance = START_CHANCE - (START_CHANCE - END_CHANCE) * Progress
	return math.clamp(math.floor(Chance), END_CHANCE, START_CHANCE)
end

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

	local ItemInfo = ItemsData[Item.Name] :: Types.Equipment
	if not ItemInfo or ItemInfo.Kind ~= "Equipment" then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "This item cannot be upgraded")
		return
	end

	if Item.Upgrades >= Item.UpgradeCap then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "Item is already at max upgrades!")
		return
	end

	local Cost = self:GetCost(Item.Upgrades)
	local Currencies = PlayerData.Currencies()

	if (Currencies.Gold or 0) < Cost then
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = player },
			"You need " .. Cost .. " Gold to upgrade this item"
		)
		return
	end

	PlayerData.Currencies()["Gold"](function(currentAmount)
		return currentAmount - Cost
	end)

	local Chance = self:GetChance(Item.Upgrades, Item.UpgradeCap)
	local Roll = math.random(1, 100)

	if Roll <= Chance then
		PlayerData.Inventory[UUID].Upgrades(Item.Upgrades + 1)
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = player },
			"Upgrade successful! " .. ItemInfo.Data.Name .. " is now +" .. (Item.Upgrades + 1)
		)
	else
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = player },
			"Upgrade failed, you lost " .. Cost .. " Gold"
		)
	end
end

return UpgradeSystem