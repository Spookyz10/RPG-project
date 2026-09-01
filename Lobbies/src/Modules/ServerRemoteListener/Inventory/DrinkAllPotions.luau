local ServerStorage = game:GetService("ServerStorage")
local InventoryManager = require(ServerStorage.Modules.InventoryManager)

local Remote = {}

function Remote:Activate(player: Player)
	InventoryManager:DrinkAllPotions(player)
end

return Remote
