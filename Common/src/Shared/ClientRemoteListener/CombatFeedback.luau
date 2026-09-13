local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFeedback = require(ReplicatedStorage.Shared.UI.UIFeedback)

local Remote = {}

function Remote:Activate(kind: string, id: string)
	if kind == "Passive" and type(id) == "string" then
		UIFeedback.Passive(id)
	end
end

return Remote
