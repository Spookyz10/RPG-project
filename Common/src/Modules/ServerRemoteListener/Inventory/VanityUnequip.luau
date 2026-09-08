local ServerStorage = game:GetService("ServerStorage")
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local Remote = {}

function Remote:Activate(player: Player, slot: string)
	InventoryManager:VanityUnequip(player, slot)
end

return Remote
