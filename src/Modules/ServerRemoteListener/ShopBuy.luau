local ServerStorage = game:GetService("ServerStorage")
local ShopHandler = require(ServerStorage.Modules.ShopHandler)

local Remote = {}

function Remote:Activate(player: Player, shopName: string, itemName: string)
	ShopHandler:Buy(player, shopName, itemName)
end

return Remote