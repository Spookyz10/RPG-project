local ServerStorage = game:GetService("ServerStorage")
local UpgradeSystem = require(ServerStorage.Modules.UpgradeSystem)

local Remote = {}

function Remote:Activate(player: Player, UUID: string)
	UpgradeSystem:UpgradeItem(player, UUID)
end

return Remote