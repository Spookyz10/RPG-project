local ServerStorage = game:GetService("ServerStorage")
local InventoryManager = require(ServerStorage.Modules.InventoryManager)

local Remote = {}

function Remote:Activate(Player: Player, skill: string, slot: string)
	InventoryManager:EquipSkill(Player, skill, slot)
end

return Remote
