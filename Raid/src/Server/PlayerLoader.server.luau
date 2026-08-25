local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DailyReward = require(ServerStorage.Modules.DailyReward)

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local CollisionGroups = require(ReplicatedStorage.Shared.CollisionGroups)
local WeaponLoader = require(ServerStorage.Modules.WeaponLoader)
local HealthManager = require(ServerStorage.Modules.HealthManager)

local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local SkillManager = require(ServerStorage.Modules.SkillManager)

local function LoadPlayer(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		warn("Failed to load data for player: " .. Player.Name)
		return
	end

	if PlayerData.FirstTimeJoined() then
		InventoryManager:AddItem(Player, "Paper Sword", 1)
		PlayerData.FirstTimeJoined(false)
	end

	SkillManager:GrantSkill(Player, "Whirlwind")
	SkillManager:Listen(Player)
	WeaponLoader:Listen(Player)
	HealthManager:Listen(Player)

	Player:LoadCharacterAsync()

	DailyReward.ResetDailyStreak(Player)
end

local function SetupCharacter(Player: Player, Character: Model)
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if PlayerData then
		local MaxHealth = HealthManager:GetMaxHealth(Player, PlayerData)
		Humanoid.MaxHealth = MaxHealth
		Humanoid.Health = MaxHealth
	end

	Humanoid.Died:Connect(function()
		if PlayerData then
			PlayerData.Deaths(function(current)
				return current + 1
			end)
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
