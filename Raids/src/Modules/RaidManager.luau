local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local RaidManager = {}

local DifficultyInstance = ReplicatedStorage:FindFirstChild("Difficulty") :: StringValue
if not DifficultyInstance then
	local NewDifficultyInstance = Instance.new("StringValue")
	NewDifficultyInstance.Name = "Difficulty"
	NewDifficultyInstance.Parent = ReplicatedStorage
	DifficultyInstance = NewDifficultyInstance
end

local DifficultyInfo = {
	["Normal"] = { RespawnTime = 5, RequiresPlayerAlive = false },
	["Hard"] = { RespawnTime = 30, RequiresPlayerAlive = true },
}

local function PlayersAlive()
	for _, player in Players:GetPlayers() do
		local Character = player.Character
		if not Character then
			continue
		end

		local Humnaoid = Character:FindFirstChild("Humanoid")
		if not Humnaoid then
			continue
		end

		if Humnaoid.Health > 0 then
			return true
		end
	end

	return false
end

function RaidManager.LoadRaid(info: { RaidName: string, Difficulty: string })
	local RaidMap = ServerStorage.Raids:FindFirstChild(info.RaidName)
	if not RaidMap then
		for _, Player in Players:GetPlayers() do
			Player:Kick("No raid map...? please contact the owner about this issue.")
		end
		return
	end

	local Map = RaidMap:Clone()
	Map.Parent = workspace
	Map.Name = "Raid"

	for _, Player in Players:GetDescendants() do
		Player:LoadCharacterAsync()
	end

	DifficultyInstance.Value = info.Difficulty
end

return RaidManager
