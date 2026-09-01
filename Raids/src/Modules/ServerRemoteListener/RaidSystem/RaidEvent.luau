local ServerStorage = game:GetService("ServerStorage")
local RaidManager = require(ServerStorage.Modules.RaidManager)
local Remote = {}

function Remote:Activate(player: Player, action: string, raidName: string?, difficulty: string?)
	if action == "Raid" then
		if typeof(raidName) ~= "string" then
			return
		end
		RaidManager:StartRaid(player, raidName, difficulty or "Normal")
	end
end

return Remote
