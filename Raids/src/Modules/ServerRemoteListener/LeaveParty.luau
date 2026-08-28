local ServerStorage = game:GetService("ServerStorage")
local PartySystem = require(ServerStorage.Modules.PartySystem)
local Remote = {}

function Remote:Activate(Player: Player)
	PartySystem:PlayerLeaveParty(Player)
end

return Remote
