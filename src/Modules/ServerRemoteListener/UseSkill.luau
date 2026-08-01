local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AttackManager = require(ServerStorage.Modules.AttackManager)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)

local Remote = {}

function Remote:Activate(Player: Player, slot: string)
	local class = PlayerClass.getPlayerInfo(Player)

	AttackManager:UseSkill(class, slot)
end

return Remote
