local ServerStorage = game:GetService("ServerStorage")
local InventoryManager = require(ServerStorage.Modules.InventoryManager)

local Remote = {}

function Remote:Activate(player: Player, UUID: string, useAll: boolean?)
	InventoryManager:ConsumeItem(player, UUID, useAll)
end

return Remote
