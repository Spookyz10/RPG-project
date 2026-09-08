local ServerStorage = game:GetService("ServerStorage")

local AttackManager = require(ServerStorage.Modules.AttackManager)

local Remote = {}

function Remote:Activate(Player: Player)
	AttackManager:Swing(Player)
end

return Remote
