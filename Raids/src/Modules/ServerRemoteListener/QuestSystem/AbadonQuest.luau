local ServerStorage = game:GetService("ServerStorage")
local QuestManager = require(ServerStorage.Modules.QuestManager)

local Remote = {}

function Remote:Activate(player: Player, questName: string)
	QuestManager:AbandonQuest(player, questName)
end

return Remote
