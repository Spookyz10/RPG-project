local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Events = require(script.Parent.Events)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local getCappedInfo = require(ReplicatedStorage.Shared.getCappedInfo)

local RewardManager = {}

function RewardManager:RollTable(itemsTable: Types.ItemTable, Player: Player): { [string]: { Amount: number } }?
	local PlayerData = Data.Service:waitForData(Player)

	if not PlayerData then
		return {}
	end

	local PlayerLuck = PlayerData.ExtraStats.Luck()

	local LuckBoost = Events:GetEventMultipliers().Luck + PlayerLuck
	local Results = {}
	for _ = 1, 1 + LuckBoost do
		for item, info in itemsTable do
			if math.random() * 100 < info.Chance then
				Results[item] = info.Chance
			end
		end
	end

	return Results
end

function RewardManager:AddCurrency(player: Player, currency: string, amount: number)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Multipliers = Events:GetEventMultipliers()
	if Multipliers[currency] then
		amount *= Multipliers[currency]
	end

	local Currencies = PlayerData.Currencies()
	if Currencies[currency] then
		PlayerData.Currencies()[currency](function(currentAmount)
			return currentAmount + amount
		end)
	else
		PlayerData.Currencies[currency](amount)
	end
end

function RewardManager:AddXP(player: Player, amount: number, mobData: Types.MobInfo?)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if mobData then
		if mobData.Level < PlayerData.Level() then
			return
		end

		if mobData.MaxLevel > PlayerData.Level() then
			return
		end
	end

	if PlayerData.Level() >= getCappedInfo.Level then
		return
	end

	amount *= Events:GetEventMultipliers().XP
	PlayerData.XP(function(currentXP)
		return currentXP + amount
	end)

	while true do
		if PlayerData.Level() >= getCappedInfo.Level then
			break
		end

		local XPNeeded = Functions:GetXPNeeded(PlayerData.Level())
		local CurrentXP = PlayerData.XP()
		if XPNeeded <= CurrentXP then
			PlayerData.XP(function(currentXP)
				return currentXP - XPNeeded
			end)
			PlayerData.Level(function(currentLevel)
				return currentLevel + 1
			end)
		else
			break
		end
	end
end

function RewardManager:AddMisc(player: Player, misc: string, amount: number)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if PlayerData[misc] then
		PlayerData[misc](function(currentAmount)
			return currentAmount + amount
		end)
	end
end

return RewardManager
