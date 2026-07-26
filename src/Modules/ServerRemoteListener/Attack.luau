local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AttackManager = require(ServerStorage.Modules.AttackManager)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)

local Remote = {}

function Remote:Activate(Player: Player)
	local class = PlayerClass.getPlayerInfo(Player)
	AttackManager:Swing(class)
end

return Remote
