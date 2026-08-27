local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TouchManager = require(ReplicatedStorage.Shared.TouchManager)
local UIModules = require(ReplicatedStorage.Shared.UI.Logic)

local LightingManager = require(ReplicatedStorage.Shared.LightingManager)
local MusicManager = require(ReplicatedStorage.Shared.MusicManager)

local Player = Players.LocalPlayer

for _, UIModule in UIModules do
	if UIModule.Init then
		UIModule.Init()
	end
end

TouchManager.Init()

local function ResetToLobby()
	LightingManager:ResetToDefault()
	MusicManager:PlayLobby()
end

local function OnCharacterAdded(character: Model)
	local Humanoid = character:WaitForChild("Humanoid") :: Humanoid
	Humanoid.Died:Connect(ResetToLobby)
end

if Player.Character then
	OnCharacterAdded(Player.Character)
end

Player.CharacterAdded:Connect(OnCharacterAdded)

ResetToLobby()
