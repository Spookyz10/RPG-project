local Remotes = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Touch = {}

function Touch.touchStarted()
	Remotes.SendServerEvent("ClaimDaily")
end

function Touch.touchEnded() end

return Touch
