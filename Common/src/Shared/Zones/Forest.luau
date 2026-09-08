local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 15,
	MaxLevel = 35,
	Description = "",
	Icon = "rbxassetid://4755199679",
	Mobs = {},
	Order = 3,
	Theme = Color3.fromRGB(9, 140, 0),
}

function Zone.getLighting()
	return {
		TimeOfDay = "14:00:00",
		Brightness = 2,
		Ambient = Color3.fromRGB(0, 85, 255),
		OutdoorAmbient = Color3.fromRGB(218, 236, 157),
		ColorShift_Bottom = Color3.fromRGB(0, 255, 0),
		ColorShift_Top = Color3.fromRGB(235, 203, 255),
	}
end

return Zone
