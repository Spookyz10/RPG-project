local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Remote = {}

function Remote:Activate(inviterName: string, duration: number)
	local PartyUI = Logic["Party"]
	if not PartyUI then
		return
	end

	PartyUI.OnInvite(inviterName, duration)
end

return Remote
