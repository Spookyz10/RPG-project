local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local LeaderboardManager = {}

local TOP_AMOUNT = 10

local Stores: { [Types.LeaderboardBoard]: OrderedDataStore } = {
	Gold = DataStoreService:GetOrderedDataStore("Leaderboard_Gold"),
	Kills = DataStoreService:GetOrderedDataStore("Leaderboard_Kills"),
	PlayTime = DataStoreService:GetOrderedDataStore("Leaderboard_PlayTime"),
}

local CachedTop: { [Types.LeaderboardBoard]: { Types.LeaderboardEntry } } = {
	Gold = {},
	Kills = {},
	PlayTime = {},
}

function LeaderboardManager:SetScore(board: Types.LeaderboardBoard, userId: number, value: number)
	local Store = Stores[board]
	if not Store then
		return
	end

	local success, err = pcall(function()
		Store:SetAsync(tostring(userId), math.max(0, math.floor(value)))
	end)

	if not success then
		warn("Failed to set " .. board .. " score for " .. userId .. ": " .. tostring(err))
	end
end

function LeaderboardManager:FetchTop(board: Types.LeaderboardBoard)
	local Store = Stores[board]
	if not Store then
		return
	end

	local success, pages = pcall(function()
		return Store:GetSortedAsync(false, TOP_AMOUNT)
	end)

	if not success then
		warn("Failed to fetch " .. board .. " leaderboard: " .. tostring(pages))
		return
	end

	local Entries: { Types.LeaderboardEntry } = {}
	for _, entry in pages:GetCurrentPage() do
		local UserId = tonumber(entry.key)
		if not UserId then
			continue
		end

		local nameSuccess, name = pcall(Players.GetNameFromUserIdAsync, Players, UserId)

		table.insert(Entries, {
			UserId = UserId,
			Name = nameSuccess and name or "Unknown",
			Value = entry.value,
		})
	end

	CachedTop[board] = Entries
	RemoteManager.SendClientEvent("LeaderboardUpdate", { All = true }, board, Entries)
end

function LeaderboardManager:GetCachedTop(board: Types.LeaderboardBoard): { Types.LeaderboardEntry }
	return CachedTop[board]
end

function LeaderboardManager:SendCacheTo(player: Player)
	for board, entries in CachedTop do
		RemoteManager.SendClientEvent("LeaderboardUpdate", { Player = player }, board, entries)
	end
end

return LeaderboardManager
