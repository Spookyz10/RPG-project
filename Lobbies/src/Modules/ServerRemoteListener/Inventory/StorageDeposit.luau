local ServerStorage = game:GetService("ServerStorage")
local StorageManager = require(ServerStorage.Modules.StorageManager)

local Remote = {}

function Remote:Activate(player: Player, UUID: string, amount: number?)
	if typeof(UUID) ~= "string" then
		return
	end

	StorageManager:ToStorage(player, UUID, amount)
end

return Remote
