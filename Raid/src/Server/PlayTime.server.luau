local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server

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
