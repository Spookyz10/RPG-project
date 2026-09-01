local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)
local Remote = {}

function Remote:Activate(player: Player, UUID: string)
	PetSystem:VanityEquipPet(player, UUID)
end

return Remote
