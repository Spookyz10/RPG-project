local ServerStorage = game:GetService("ServerStorage")
local PartySystem = require(ServerStorage.Modules.PartySystem)
local Remote = {}

function Remote:Activate(Player: Player, inviterName: string)
	if typeof(inviterName) ~= "string" then
		return
	end
	PartySystem:AcceptInvite(Player, inviterName)
end

return Remote
