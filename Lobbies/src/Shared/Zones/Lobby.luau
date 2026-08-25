local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 1,
	MaxLevel = 1,
	Description = "lobbywse",
	Icon = "",
	Mobs = {},
}

function Zone.getLighting()
	return {
		ClockTime = "14:00:00",
		Ambient = Color3.fromRGB(10, 255, 104),
		OutdoorAmbient = Color3.fromRGB(136, 223, 255),
	}
end

return Zone
