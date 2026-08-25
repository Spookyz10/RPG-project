local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local LeaderboardManager = require(ServerStorage.Modules.LeaderboardManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SYNC_INTERVAL = 30
local Boards: { Types.LeaderboardBoard } = { "Gold", "Kills", "PlayTime" }

local function SyncPlayer(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	LeaderboardManager:SetScore("Gold", player.UserId, PlayerData.Currencies().Gold or 0)
	LeaderboardManager:SetScore("Kills", player.UserId, PlayerData.Kills())
	LeaderboardManager:SetScore("PlayTime", player.UserId, PlayerData.PlayTime())
end

Players.PlayerAdded:Connect(function(player)
	LeaderboardManager:SendCacheTo(player)
end)

Players.PlayerRemoving:Connect(SyncPlayer)

while true do
	for _, player in Players:GetPlayers() do
		SyncPlayer(player)
	end

	for _, board in Boards do
		LeaderboardManager:FetchTop(board)
	end

	task.wait(SYNC_INTERVAL)
end
