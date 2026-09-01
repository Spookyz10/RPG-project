local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)
local Remote = {}

function Remote:Activate(player: Player)
	PetSystem:VanityUnequipPet(player)
end

return Remote
