local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Remote = {}

function Remote:Activate(player: Player)
	local playerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not playerData or playerData.FirstTimeJoined() ~= true then
		return
	end

	playerData.FirstTimeJoined(false)
	player:SetAttribute("ShowTutorial", false)
end

return Remote
