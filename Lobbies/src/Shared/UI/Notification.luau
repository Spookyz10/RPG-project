local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local UIConstants = require(script.Parent.UIConstants)
local Notification = {}

function Notification.Start(message: string)
	local Template = ReplicatedStorage.Assets.UI.Templates.Notification:Clone()
	Template.Parent = UIConstants.PlayerGui.Overlap.NotificationContainer
	Functions:TypeWrite(Template.Label, message)

	Debris:AddItem(Template)
end

return Notification
