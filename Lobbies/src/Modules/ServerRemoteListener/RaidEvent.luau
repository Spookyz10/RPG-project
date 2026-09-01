local ServerStorage = game:GetService("ServerStorage")
local RaidManager = require(ServerStorage.Modules.RaidManager)
local Remote = {}

function Remote:Activate(player: Player, action: string, raidName: string?, hardcore: boolean?)
	if action == "Raid" then
		if typeof(raidName) ~= "string" then
			return
		end
		RaidManager:StartRaid(player, raidName, hardcore == true)
	elseif action == "Leave" then
		RaidManager:AbandonRaid(player)
	end
end

return Remote
