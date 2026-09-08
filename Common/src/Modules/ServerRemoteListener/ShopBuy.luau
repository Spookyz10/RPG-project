local ServerStorage = game:GetService("ServerStorage")
local ShopHandler = require(ServerStorage.Modules.ShopHandler)
local Remotes = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)

local Remote = {}

function Remote:Activate(player: Player, shopName: string, itemName: string)
	local message = ShopHandler:Buy(player, shopName, itemName)
	Remotes.SendClientEvent("Notification", { Player = player }, message)
end

return Remote
