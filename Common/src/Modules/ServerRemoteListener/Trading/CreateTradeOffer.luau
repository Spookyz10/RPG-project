local ServerStorage = game:GetService("ServerStorage")
local RemoteManager = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local TradeSystem = require(ServerStorage.Modules.TradeSystem)

local Remote = {}

function Remote:Activate(player: Player, target: Player, payload: any)
	local _, message = TradeSystem:CreateOffer(player, target, payload)
	if message ~= "Trade offer sent" then
		RemoteManager.SendClientEvent("Notification", { Player = player }, message)
	end
end

return Remote
