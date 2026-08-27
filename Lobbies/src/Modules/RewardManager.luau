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

	local LuckMultiplier = Events:GetEventMultipliers().Luck

	local Results = {}
	for item, info in itemsTable do
		local BoostedChance = math.min(info.Chance * LuckMultiplier, 100)
		if math.random() * 100 < BoostedChance then
			Results[item] = info.Amount
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
		PlayerData.Currencies[currency](function(currentAmount)
			return currentAmount + amount
		end)
	else
		PlayerData.Currencies[currency](amount)
	end
end

type XPParams = {
	["MobData"]: Types.MobInfo?,
	["QuestInfo"]: Types.QuestInfo?,
}

function RewardManager:AddXP(player: Player, amount: number, params: XPParams?)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	params = params or {}

	local mobData = params.MobData
	local questData = params.QuestInfo

	if mobData then
		if PlayerData.Level() > mobData.MaxLevel then
			return
		end
	end

	if questData then
		if questData.MaxLevel and questData.MaxLevel > PlayerData.Level() then
			return
		end
	end

	amount *= Events:GetEventMultipliers().XP
	PlayerData.XP(function(currentXP)
		return currentXP + amount
	end)

	local IsMaxLevel = PlayerData.Level() >= getCappedInfo.Level

	while true do
		local XPNeeded = Functions:GetXPNeeded(PlayerData.Level())
		local CurrentXP = PlayerData.XP()

		if XPNeeded > CurrentXP then
			break
		end

		PlayerData.XP(function(currentXP)
			return currentXP - XPNeeded
		end)

		if IsMaxLevel then
			PlayerData.Honor(function(currentHonor)
				return currentHonor + 1
			end)
		else
			PlayerData.Level(function(currentLevel)
				return currentLevel + 1
			end)

			if PlayerData.Level() >= getCappedInfo.Level then
				IsMaxLevel = true
			end
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
