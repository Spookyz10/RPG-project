local ServerStorage = game:GetService("ServerStorage")
local InventoryManager = require(ServerStorage.Modules.InventoryManager)
local Remote = {}

function Remote:Activate(player: Player, UUID: string)
	InventoryManager:UnequipItem(player, UUID)
end

return Remote
