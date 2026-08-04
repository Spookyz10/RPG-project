local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Notification = require(ReplicatedStorage.Shared.UI.Notification)

local Remote = {}

function Remote:Activate(message: string)
	Notification.Start(message)
end

return Remote
