local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Data = require(ReplicatedStorage.Shared.Data).server
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local PlayerStatsReplicator = {}

local ListenedPlayers: { [Player]: boolean } = {}

local function getOrCreateFolder(player: Player): Folder
	local Existing = player:FindFirstChild("PublicStats")
	if Existing then
		return Existing
	end

	local Folder = Instance.new("Folder")
	Folder.Name = "PublicStats"
	Folder.Parent = player

	local Level = Instance.new("NumberValue")
	Level.Name = "Level"
	Level.Parent = Folder

	local Honor = Instance.new("NumberValue")
	Honor.Name = "Honor"
	Honor.Parent = Folder

	return Folder
end

function PlayerStatsReplicator:Listen(player: Player)
	if ListenedPlayers[player] then
		return
	end
	ListenedPlayers[player] = true

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Folder = getOrCreateFolder(player)
	local LevelValue = Folder.Level :: NumberValue
	local HonorValue = Folder.Honor :: NumberValue

	LevelValue.Value = PlayerData.Level()
	HonorValue.Value = PlayerData.Honor()

	PlayerData.Level.Changed(function(newLevel)
		LevelValue.Value = newLevel
	end)

	PlayerData.Honor.Changed(function(newHonor)
		HonorValue.Value = newHonor
	end)
end

Players.PlayerRemoving:Connect(function(player: Player)
	ListenedPlayers[player] = nil
end)

return PlayerStatsReplicator
