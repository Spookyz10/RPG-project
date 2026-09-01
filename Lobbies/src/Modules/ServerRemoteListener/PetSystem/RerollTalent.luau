local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)

local Remote = {}

function Remote:Invoke(player: Player, UUID: string)
	if typeof(UUID) ~= "string" then
		return false, "Invalid UUID"
	end

	return PetSystem:RerollTalent(player, UUID)
end

return Remote
