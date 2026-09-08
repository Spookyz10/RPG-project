local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local MusicManager = {}

local ZonesFolder = ReplicatedStorage.Resources.Music.Zones

local CurrentSound: Sound? = nil

local function PlayRandomFrom(folder: Instance)
	local Tracks = folder:GetChildren()
	if #Tracks == 0 then
		return
	end

	local Track = Tracks[math.random(1, #Tracks)] :: Sound

	if CurrentSound then
		CurrentSound:Stop()
		CurrentSound:Destroy()
		CurrentSound = nil
	end

	local NewSound = Track:Clone()
	NewSound.Parent = SoundService
	NewSound:Play()

	CurrentSound = NewSound
end

function MusicManager:PlayZone(zoneName: string)
	local ZoneFolder = ZonesFolder:FindFirstChild(zoneName)
	if not ZoneFolder then
		return
	end

	PlayRandomFrom(ZoneFolder)
end

function MusicManager:PlayLobby()
	self:PlayZone("Lobby")
end

return MusicManager
