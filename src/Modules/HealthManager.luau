local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local HealthManager = {}

local BASE_HEALTH = 100
local REGEN_INTERVAL = 1
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

	local Entity = PlayerClass.getPlayerInfo(player)
	if not Entity then
		return
	end

	local NewMaxHP = self:GetMaxHealth(player, PlayerData)

	PlayerClass.setMaxHP(player, NewMaxHP)

	if Entity.HP > NewMaxHP then
		PlayerClass.setHP(player, NewMaxHP)
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

			local Entity = PlayerClass.getPlayerInfo(player)
			if not Entity then
				continue
			end

			if Entity.HP <= 0 or Entity.HP >= Entity.MaxHP then
				continue
			end

			local RegenAmount = math.ceil(Entity.MaxHP * REGEN_PERCENT)
			local NewHP = math.min(Entity.MaxHP, Entity.HP + RegenAmount)

			PlayerClass.setHP(player, NewHP)
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

Players.PlayerRemoving:Connect(function(player: Player)
	ListenedPlayers[player] = nil
	ActiveRegenLoops[player] = nil
end)

return HealthManager
