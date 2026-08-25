local ServerStorage = game:GetService("ServerStorage")
local CraftingService = require(ServerStorage.Modules.CraftingService)

local Remote = {}

function Remote:Activate(player: Player, item: string)
	CraftingService:CraftItem(item, player)
end

return Remote
