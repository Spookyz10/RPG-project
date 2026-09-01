local ServerStorage = game:GetService("ServerStorage")
local PartySystem = require(ServerStorage.Modules.PartySystem)
local Remote = {}

function Remote:Activate(Player: Player, Member: Player)
	PartySystem:InvitePlayer(Player, Member)
end

return Remote
