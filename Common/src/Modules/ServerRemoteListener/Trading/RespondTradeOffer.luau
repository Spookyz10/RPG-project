local ServerStorage = game:GetService("ServerStorage")
local RemoteManager = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local TradeSystem = require(ServerStorage.Modules.TradeSystem)

local Remote = {}

function Remote:Activate(player: Player, offerId: string, accept: boolean)
	local ok, message = TradeSystem:Respond(player, offerId, accept)
	if not ok then
		RemoteManager.SendClientEvent("Notification", { Player = player }, message)
	end
end

return Remote
