local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local TouchManager = require(ReplicatedStorage.Shared.TouchManager)
local UIModules = require(ReplicatedStorage.Shared.UI.Logic)

local LightingManager = require(ReplicatedStorage.Shared.LightingManager)

local Player = Players.LocalPlayer

for _, UIModule in UIModules do
	if UIModule.Init then
		UIModule.Init()
	end
end

TouchManager.Init()

local function PlayLobbyMusic()
	local LobbyFolder = ReplicatedStorage.Resources.Music:FindFirstChild("Lobby")
	if not LobbyFolder then
		return
	end

	local Tracks = LobbyFolder:GetChildren()
	if #Tracks == 0 then
		return
	end

	local Track = Tracks[math.random(1, #Tracks)]
	local MainSound = SoundService:FindFirstChild("Sound")
	if MainSound and Track:IsA("Sound") then
		MainSound.SoundId = Track.SoundId
		MainSound:Play()
	end
end

local function ResetToLobby()
	LightingManager:ResetToDefault()
	PlayLobbyMusic()
end

local function OnCharacterAdded(character: Model)
	local Humanoid = character:WaitForChild("Humanoid") :: Humanoid
	Humanoid.Died:Connect(ResetToLobby)
end

if Player.Character then
	OnCharacterAdded(Player.Character)
end

Player.CharacterAdded:Connect(OnCharacterAdded)
