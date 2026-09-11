local RS = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local Access = require(RS.Shared.AdminAccess)
local Remote = {}
function Remote:Activate(message)
	if not Access[player.UserId] or typeof(message) ~= "string" then return end
	local screen = player.PlayerGui:FindFirstChild("Main")
	if screen then screen.Admin.Body.Content.Status.Text = message end
end
return Remote
