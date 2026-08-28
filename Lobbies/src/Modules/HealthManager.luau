local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local HealthManager = {}

local BASE_HEALTH = 100
local REGEN_INTERVAL = 3
local REGEN_PERCENT = 0.01

local ListenedPlayers: { [Player]: boolean } = {}
local ActiveRegenLoops: { [Player]: boolean } = {}

function HealthManager:GetMaxHealth(player: Player, PlayerData: Types.PlayerData): number
	local Stats = Functions:GetTotalStats(player.Character, PlayerData())
	return Stats.Health + BASE_HEALTH
end

function HealthManager:Refresh(player: Player)
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

	local NewMaxHP = self:GetMaxHealth(player, PlayerData)

	Humanoid.MaxHealth = NewMaxHP

	if Humanoid.Health > NewMaxHP then
		Humanoid.Health = NewMaxHP
	end
end

local function StartRegen(player: Player)
	if ActiveRegenLoops[player] then
		return
	end
	ActiveRegenLoops[player] = true

	task.spawn(function()
		while ActiveRegenLoops[player] and player.Parent do
			task.wait(REGEN_INTERVAL)

			if not ActiveRegenLoops[player] or not player.Parent then
				break
			end

			local Character = player.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				continue
			end

			if Humanoid.Health <= 0 or Humanoid.Health >= Humanoid.MaxHealth then
				continue
			end

			local RegenAmount = math.ceil(Humanoid.MaxHealth * REGEN_PERCENT)
			Humanoid.Health = math.min(Humanoid.MaxHealth, Humanoid.Health + RegenAmount)
		end
	end)
end

function HealthManager:Listen(player: Player)
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

	StartRegen(player)
end

function HealthManager.OnPlayerRemoved(Player: Player)
	ListenedPlayers[Player] = nil
	ActiveRegenLoops[Player] = nil
end

return HealthManager
