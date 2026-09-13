local ServerStorage = game:GetService("ServerStorage")
local TradeSystem = require(ServerStorage.Modules.TradeSystem)

local Remote = {}

function Remote:Invoke(player: Player, target: Player)
	return TradeSystem:GetCatalog(player, target)
end

return Remote
