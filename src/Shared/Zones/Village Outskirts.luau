local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 1,
	MaxLevel = 1,
	Description = "A bilalge",
	Icon = "",
	Mobs = { "Wolf" },
}

function Zone.ApplyLighting()
	Lighting.ClockTime = "14:00:00"
	Lighting.Ambient = Color3.fromRGB(10, 255, 104)
	Lighting.OutdoorAmbient = Color3.fromRGB(136, 223, 255)
end

return Zone
