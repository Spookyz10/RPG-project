local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IndicatorSystem = require(ReplicatedStorage.Shared.IndicatorSystem)

local Remote = {}

function Remote:Activate(indicatorName: string, color: {}, position: CFrame | Vector3, time: number, size: Vector3?)
	IndicatorSystem:CreateIndicator(indicatorName, color, position, time, size)
end

return Remote
