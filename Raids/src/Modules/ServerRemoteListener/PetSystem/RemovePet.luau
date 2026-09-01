local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)
local Remote = {}

function Remote:Activate(player: Player, UUID: string)
	PetSystem:RemovePet(player, UUID)
end

return Remote
