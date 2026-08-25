local ServerStorage = game:GetService("ServerStorage")
local QuestManager = require(ServerStorage.Modules.QuestManager)

local Remote = {}

function Remote:Activate(player: Player, questName: string, skipChain: boolean?)
	QuestManager:AcceptQuest(player, questName, skipChain)
end

return Remote
