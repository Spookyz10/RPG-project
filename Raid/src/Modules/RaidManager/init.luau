local ServerScriptService = game:GetService("ServerScriptService")
local RaidManager = {}

local Raids = {}

for _, Raid in script.Raids:GetDescendants() do
	if Raid:IsA("ModuleScript") then
		Raids[Raid.Name] = require(Raid)
	end
end

function RaidManager.SpawnRaid(raidName: string)
	local Map = ServerScriptService:FindFirstChild("Raids"):FindFirstChild(raidName):Clone()
	Map.Parent = workspace
	Map.Name = "Map"
end

function RaidManager.Start(raidName)
	if Raids[raidName] and Raids[raidName].Start then
		Raids[raidName].Start()
	end
end

return RaidManager
