local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local WeaponLoader = require(ServerStorage.Modules.WeaponLoader)

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
		InventoryManager:AddItem(Player, "Wooden Sword", 1)
		PlayerData.FirstTimeJoined(false)
	end

	SkillManager:GrantSkill(Player, "Whirlwind")
	SkillManager:Listen(Player)
	WeaponLoader:Listen(Player)

	Player:LoadCharacterAsync()
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
	LoadPlayer(player)
	local PlayerStats = Functions:GetTotalStats(nil, Data.Service:waitForData(player))
	PlayerClass.addPlayer(player, PlayerStats.Health + 100)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerClass.removePlayer(player)
end)
