local ServerStorage = game:GetService("ServerStorage")
local SellManager = require(ServerStorage.Modules.SellManager)

local Remote = {}

function Remote:Activate(player: Player, sellList: { [string]: number })
	SellManager:SellItems(player, sellList)
end

return Remote
