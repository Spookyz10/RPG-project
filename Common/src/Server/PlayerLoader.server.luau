local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ComboManager = require(ServerStorage.Modules.ComboManager)
local CooldownSystem = require(ServerStorage.Modules.CooldownSystem)
local DailyReward = require(ServerStorage.Modules.DailyReward)
local EquipmentPassives = require(ServerStorage.Modules.EquipmentPassives)

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local CollisionGroups = require(ReplicatedStorage.Shared.CollisionGroups)
local WeaponLoader = require(ServerStorage.Modules.WeaponLoader)
local HealthManager = require(ServerStorage.Modules.HealthManager)

local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local PartySystem = require(ServerStorage.Modules.PartySystem)
local QuestManager = require(ServerStorage.Modules.QuestManager)
local SpeedManager = require(ServerStorage.Modules.SpeedManager)
local StatsReplicator = require(ServerStorage.Modules.StatsReplicator)
local StunManager = require(ServerStorage.Modules.StunManager)
local TradeSystem = require(ServerStorage.Modules.TradeSystem)

local RESPAWN_TIME = 6
local LEGACY_STARTER_WEAPON = "Paper Sword"
local STARTER_WEAPON = "Wooden Sword"

local function FindStarterWeapon(PlayerData: Types.PlayerData): string?
	for UUID, item in PlayerData.Inventory() do
		if item.ID == STARTER_WEAPON or item.Name == STARTER_WEAPON then
			return UUID
		end
	end
	return nil
end

local function MigrateStarterWeapon(PlayerData: Types.PlayerData)
	for UUID, item in PlayerData.Inventory() do
		if item.ID == LEGACY_STARTER_WEAPON then
			PlayerData.Inventory[UUID].ID(STARTER_WEAPON)
			PlayerData.Inventory[UUID].Name(STARTER_WEAPON)
		end
	end
end

local function LoadPlayer(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		warn("Failed to load data for player: " .. Player.Name)
		return
	end
	MigrateStarterWeapon(PlayerData)

	Player:SetAttribute("ShowTutorial", PlayerData.FirstTimeJoined())
	if PlayerData.FirstTimeJoined() then
		local UUID = FindStarterWeapon(PlayerData)
		if not UUID then
			local _, addedUUID = InventoryManager:AddItem(Player, STARTER_WEAPON, 1)
			UUID = addedUUID
		end
		if UUID and PlayerData.Equipment.Weapon() == UUID then
			InventoryManager:UnequipItem(Player, UUID)
		end
		for slot, skill in PlayerData.Skills() do
			if skill == "Cyclone" then
				PlayerData.Skills[slot]("")
			end
		end
		QuestManager:AcceptQuest(Player, "Tutorial1")
	end

	WeaponLoader:Listen(Player)
	HealthManager:Listen(Player)
	StatsReplicator:Listen(Player)
	SpeedManager:Listen(Player)
	EquipmentPassives:Listen(Player, PlayerData)
	Player:LoadCharacterAsync()
	DailyReward.ResetDailyStreak(Player)

	Player:WaitForChild("PlayerGui"):WaitForChild("LoadingScreen").Enabled = true
end

local function SetupCharacter(Player: Player, Character: Model)
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	-- Created on the server so tracks started by the owning client can replicate.
	if not Humanoid:FindFirstChildOfClass("Animator") then
		Instance.new("Animator", Humanoid)
	end

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if PlayerData then
		local MaxHealth = HealthManager:GetMaxHealth(Player, PlayerData)
		Humanoid.MaxHealth = MaxHealth
		Humanoid.Health = MaxHealth
	end


	Humanoid.Died:Connect(function()
		require(ServerStorage.Modules.MobDeath):Play(Character)
		if PlayerData then
			PlayerData.Deaths(function(current)
				return current + 1
			end)
		end

		local token = (Player:GetAttribute("RespawnToken") or 0) + 1
		Player:SetAttribute("RespawnToken", token)
		task.wait(RESPAWN_TIME)
		if Player and Player.Parent and Player:GetAttribute("RespawnToken") == token then
			Player:LoadCharacterAsync()
		end
	end)
end

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character)
		CollisionGroups:Apply(character)
		SetupCharacter(player, character)
	end)

	LoadPlayer(player)
end)

Players.PlayerRemoving:Connect(function(Player)
	ComboManager:ClearPlayer(Player)
	CooldownSystem.OnPlayerRemoved(Player)
	EquipmentPassives.OnPlayerRemoved(Player)
	HealthManager.OnPlayerRemoved(Player)
	SpeedManager.OnPlayerRemoved(Player)
	StatsReplicator.OnPlayerRemoved(Player)
	PartySystem:OnPlayerRemoved(Player)
	TradeSystem:OnPlayerRemoved(Player)
	StunManager.OnPlayerRemoved(Player)
end)
