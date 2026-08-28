local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SpeedManager = {}

local BASE_WALKSPEED = 16

local ListenedPlayers: { [Player]: boolean } = {}

function SpeedManager:GetWalkSpeed(player: Player, PlayerData: Types.PlayerData): number
	local Stats = Functions:GetTotalStats(player.Character, PlayerData())
	return BASE_WALKSPEED + Stats.Speed
end

function SpeedManager:Refresh(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Character = player.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return
	end

	Humanoid.WalkSpeed = self:GetWalkSpeed(player, PlayerData)
end

function SpeedManager:Listen(player: Player)
	if ListenedPlayers[player] then
		return
	end
	ListenedPlayers[player] = true

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	PlayerData.Equipment.Changed(function()
		self:Refresh(player)
	end)

	PlayerData.ExtraStats.Changed(function()
		self:Refresh(player)
	end)

	player.CharacterAdded:Connect(function()
		self:Refresh(player)
	end)

	if player.Character then
		self:Refresh(player)
	end
end

function SpeedManager.OnPlayerRemoved(Player: Player)
	ListenedPlayers[Player] = nil
end

return SpeedManager
