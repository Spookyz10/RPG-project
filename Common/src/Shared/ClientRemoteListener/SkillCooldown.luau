local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Remote = {}

function Remote:Activate(slot: string, time: number, skillName: string?)
	Logic["CooldownUI"].StartCooldown(slot, time, skillName)
end

return Remote
