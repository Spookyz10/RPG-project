local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = {}

UIConstants.Player = Players.LocalPlayer
UIConstants.PlayerGui = UIConstants.Player:WaitForChild("PlayerGui")

UIConstants.Data = require(ReplicatedStorage.Shared.Data).client

UIConstants.Character = UIConstants.Player.Character or UIConstants.Player.CharacterAdded:Wait()

UIConstants.Player.CharacterAdded:Connect(function(newCharacter)
	UIConstants.Character = newCharacter
end)

return UIConstants
