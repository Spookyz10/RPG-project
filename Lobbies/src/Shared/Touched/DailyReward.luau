local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Touch: Types.Touch = {}

function Touch.touchStarted()
	RemoteManager.SendServerEvent("ClaimDaily")
end

return Touch
