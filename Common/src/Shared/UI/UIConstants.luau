local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = {}

UIConstants.Player = Players.LocalPlayer
UIConstants.PlayerGui = require(script.Parent.Bootstrap).Ensure()

UIConstants.Data = require(ReplicatedStorage.Shared.Data).client

UIConstants.Character = UIConstants.Player.Character

UIConstants.Player.CharacterAdded:Connect(function(newCharacter)
	UIConstants.Character = newCharacter
end)

return UIConstants
