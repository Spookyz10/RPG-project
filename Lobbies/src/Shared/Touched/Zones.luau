local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Touch: Types.Touch = {}

function Touch.touchStarted()
	print("Touch started")
end

function Touch.touchEnded()
	print("Touch ended")
end

return Touch
