local ServerStorage = game:GetService("ServerStorage")

local AttackManager = require(ServerStorage.Modules.AttackManager)

local Remote = {}

function Remote:Activate(Player: Player, slot: string)
	AttackManager:UseSkill(Player, slot)
end

return Remote
