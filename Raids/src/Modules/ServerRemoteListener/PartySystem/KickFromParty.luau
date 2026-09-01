local ServerStorage = game:GetService("ServerStorage")
local PartySystem = require(ServerStorage.Modules.PartySystem)
local Remote = {}

function Remote:Activate(Player: Player, targetName: string)
	if typeof(targetName) ~= "string" then
		return
	end
	PartySystem:KickPlayer(Player, targetName)
end

return Remote
