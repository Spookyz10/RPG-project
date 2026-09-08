local ServerStorage = game:GetService("ServerStorage")
local RaidManager = require(ServerStorage.Modules.RaidManager)

local Remote = {}

function Remote:Activate(player: Player, itemName: string)
	RaidManager:ToggleAutoDelete(player, itemName)
end

return Remote
