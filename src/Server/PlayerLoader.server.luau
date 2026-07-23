local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)

Players.PlayerAdded:Connect(function(player: Player)
	PlayerClass.addPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerClass.removePlayer(player)
end)
