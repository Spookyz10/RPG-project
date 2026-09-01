local ServerStorage = game:GetService("ServerStorage")
local PetSystem = require(ServerStorage.Modules.PetSystem)

local Remote = {}

function Remote:Invoke(player: Player, boxRarity: string, amount: number)
	if typeof(boxRarity) ~= "string" then
		return false, "Invalid box", {}
	end

	if typeof(amount) ~= "number" then
		return false, "Invalid amount", {}
	end

	return PetSystem:BuyBox(player, boxRarity, amount)
end

return Remote
