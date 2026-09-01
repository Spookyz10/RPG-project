local ServerStorage = game:GetService("ServerStorage")
local SkillManager = require(ServerStorage.Modules.SkillManager)

local Remote = {}

function Remote:Activate(player: Player, skill: string, slot: string)
	SkillManager:EquipSkill(player, skill, slot)
end

return Remote
