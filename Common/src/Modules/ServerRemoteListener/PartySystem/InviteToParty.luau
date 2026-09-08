local ServerStorage = game:GetService("ServerStorage")
local PartySystem = require(ServerStorage.Modules.PartySystem)
local Remotes = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Remote = {}

function Remote:Activate(Player: Player, Member: Player)
	local _, message = PartySystem:InvitePlayer(Player, Member)
	Remotes.SendClientEvent("Notification", { Player = Player }, message)
end

return Remote
