local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ComboManager = require(ServerStorage.Modules.ComboManager)
local CooldownSystem = require(ServerStorage.Modules.CooldownSystem)
local DailyReward = require(ServerStorage.Modules.DailyReward)

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local CollisionGroups = require(ReplicatedStorage.Shared.CollisionGroups)
local WeldSystem = require(ReplicatedStorage.Shared.Utils.WeldSystem)
local WeaponLoader = require(ServerStorage.Modules.WeaponLoader)
local HealthManager = require(ServerStorage.Modules.HealthManager)

local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local PartySystem = require(ServerStorage.Modules.PartySystem)
local RaidManager = require(ServerStorage.Modules.RaidManager)

local SpeedManager = require(ServerStorage.Modules.SpeedManager)
local StatsReplicator = require(ServerStorage.Modules.StatsReplicator)

local function LoadPlayer(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		warn("Failed to load data for player: " .. Player.Name)
		return
	end

	if PlayerData.FirstTimeJoined() then
		local _, UUID = InventoryManager:AddItem(Player, "Paper Sword", 1)
		if UUID then
			InventoryManager:ItemAction(Player, UUID)
		end
		PlayerData.FirstTimeJoined(false)
	end

	WeaponLoader:Listen(Player)
	HealthManager:Listen(Player)
	StatsReplicator:Listen(Player)

	DailyReward.ResetDailyStreak(Player)
end

local function SetupHitbox(Character: Model)
	local RootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not RootPart then
		return
	end

	local Template = ReplicatedStorage.Resources:FindFirstChild("Hitbox") :: BasePart?
	if not Template then
		warn("Resources.Hitbox not found")
		return
	end

	local HitboxPart = Template:Clone()
	HitboxPart.Parent = Character
	HitboxPart:PivotTo(RootPart.CFrame)

	WeldSystem:Weld(RootPart, HitboxPart)
end

local function SetupCharacter(Player: Player, Character: Model)
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if PlayerData then
		local MaxHealth = HealthManager:GetMaxHealth(Player, PlayerData)
		Humanoid.MaxHealth = MaxHealth
		Humanoid.Health = MaxHealth
	end

	SetupHitbox(Character)

	Humanoid.Died:Connect(function()
		if PlayerData then
			PlayerData.Deaths(function(current)
				return current + 1
			end)
		end
	end)
end

local Loaded = false

Players.PlayerAdded:Connect(function(player: Player)
	if not Loaded then
		local info = player:GetJoinData().TeleportData
		if info then
			RaidManager.LoadRaid(info.RaidName)
			Loaded = true
		end
	end

	player.CharacterAdded:Connect(function(character)
		CollisionGroups:Apply(character)
		SetupCharacter(player, character)
	end)

	LoadPlayer(player)
end)

Players.PlayerRemoving:Connect(function(Player)
	ComboManager:ClearPlayer(Player)
	CooldownSystem.OnPlayerRemoved(Player)
	HealthManager.OnPlayerRemoved(Player)
	SpeedManager.OnPlayerRemoved(Player)
	StatsReplicator.OnPlayerRemoved(Player)
	PartySystem:OnPlayerRemoved(Player)
end)
