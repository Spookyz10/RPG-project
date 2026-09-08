local ServerStorage = game:GetService("ServerStorage")
local QuestManager = require(ServerStorage.Modules.QuestManager)
local Remotes = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)

local Remote = {}

function Remote:Activate(player: Player, questName: string)
	local _, message = QuestManager:AbandonQuest(player, questName)
	Remotes.SendClientEvent("Notification", { Player = player }, message)
end

return Remote
