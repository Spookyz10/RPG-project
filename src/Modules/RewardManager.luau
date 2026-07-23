local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local Events = require(script.Parent.Events)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RewardManager = {}

function RewardManager:RollTable(itemsTable: Types.ItemTable, Player: Player): { [string]: { Amount: number } }?
	local PlayerLuck = Data.Service:waitForData(Player).Stats.Luck()
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

return RewardManager
