local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server

local function joined(player)
	player:SetAttribute("SessionStartedAt", workspace:GetServerTimeNow())
end
Players.PlayerAdded:Connect(joined)
for _, player in Players:GetPlayers() do joined(player) end

while true do
	task.wait(1)

	for _, player in Players:GetPlayers() do
		local PlayerData = Data.Service:waitForData(player)
		if PlayerData then
			PlayerData.PlayTime(function(current)
				return current + 1
			end)
		end
	end
end
