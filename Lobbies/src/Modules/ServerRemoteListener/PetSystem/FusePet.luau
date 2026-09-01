local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)
local Remote = {}

function Remote:Invoke(player: Player, targetUUID: string, catalystUUID: string?)
	if catalystUUID == "All" then
		return PetSystem:FuseAll(player, targetUUID)
	end

	return PetSystem:FusePet(player, targetUUID, catalystUUID)
end

return Remote
