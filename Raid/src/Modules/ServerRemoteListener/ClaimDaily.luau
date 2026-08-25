local ServerStorage = game:GetService("ServerStorage")
local DailyReward = require(ServerStorage.Modules.DailyReward)

local Remote = {}

function Remote:Activate(player: Player)
	DailyReward.ClaimDaily(player)
end

return Remote
