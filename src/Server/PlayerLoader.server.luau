local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)

local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(ServerStorage.Modules.InventoryManager)

local function LoadPlayer(Player: Player)
	local PlayerData = Data.Service:waitForData(Player)
	if not PlayerData then
		warn("Failed to load data for player: " .. Player.Name)
		return
	end

	if PlayerData.FirstTimeJoined() then
		InventoryManager:AddItem(Player, "Wooden Sword", 1)
		PlayerData.FirstTimeJoined(false)
		print("Given sword")
		print(PlayerData.Inventory())
	else
		print("Player has already joined")
		print(PlayerData.Inventory())
	end

	Player:LoadCharacterAsync()
end

Players.PlayerAdded:Connect(function(player: Player)
	PlayerClass.addPlayer(player)
	LoadPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerClass.removePlayer(player)
end)
