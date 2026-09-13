local Transition = require(game:GetService("ReplicatedStorage").Shared.UI.ZoneTransition)
local RemoteManager = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)

return {
	Activate = function(_, destination)
		Transition.Play(tostring(destination), function()
			RemoteManager.SendServerEvent("ZoneTransitionReady")
		end)
	end,
}
