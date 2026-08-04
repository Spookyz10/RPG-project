local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DailyReward = require(ServerStorage.Modules.DailyReward)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local CollisionGroups = require(ReplicatedStorage.Shared.CollisionGroups)
local WeaponLoader = require(ServerStorage.Modules.WeaponLoader)
local HealthManager = require(ServerStorage.Modules.HealthManager)

local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local SkillManager = require(ServerStorage.Modules.SkillManager)

local RESPAWN_TIME = 6

Players.CharacterAutoLoads = false

local function LoadPlayer(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		warn("Failed to load data for player: " .. Player.Name)
		return
	end

	if PlayerData.FirstTimeJoined() then
		InventoryManager:AddItem(Player, "Wooden Sword", 1)
		PlayerData.FirstTimeJoined(false)
	end

	SkillManager:GrantSkill(Player, "Whirlwind")
	SkillManager:Listen(Player)
	WeaponLoader:Listen(Player)

	Player:LoadCharacterAsync()

	local InitialHealth = HealthManager:GetMaxHealth(Player, PlayerData)
	PlayerClass.addPlayer(Player, InitialHealth)
	HealthManager:Listen(Player)

	DailyReward.ResetDailyStreak(Player)
end

local function SetupRespawn(Player: Player, Character: Model)
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	Humanoid.Died:Connect(function()
		task.wait(RESPAWN_TIME)
		if Player and Player.Parent then
			Player:LoadCharacterAsync()
		end
	end)
end

PlayerClass.Died:Connect(function(player: Player)
	local PlayerData = Data.Service:waitForData(player)
	if PlayerData then
		PlayerData.Deaths(function(current)
			return current + 1
		end)
	end
end)

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character)
		CollisionGroups:Apply(character)
		SetupRespawn(player, character)
	end)

	LoadPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerClass.removePlayer(player)
end)
