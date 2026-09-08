local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Remote = {}

function Remote:Activate(action: string, ...: any)
	local PartyUI = Logic["Party"]
	if not PartyUI then
		return
	end

	if action == "PartyUpdate" then
		PartyUI.OnUpdate(...)
	elseif action == "Leave" then
		PartyUI.OnLeave()
	end
end

return Remote