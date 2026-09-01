local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)
local Remote = {}

function Remote:Activate(player: Player, UUID: string)
	PetSystem:LockPet(player, UUID)
end

return Remote
