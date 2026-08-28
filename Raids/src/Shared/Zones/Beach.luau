local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 22,
	MaxLevel = 50,
	Description = "",
	Icon = "rbxassetid://4755199677",
	Mobs = {},
	Order = 4,
	Theme = Color3.fromRGB(0, 229, 255),
}

function Zone.getLighting()
	return {
		TimeOfDay = "14:00:00",
		Brightness = 2,
		Ambient = Color3.fromRGB(245, 220, 255),
		OutdoorAmbient = Color3.fromRGB(255, 236, 180),
		ColorShift_Bottom = Color3.fromRGB(245, 220, 255),
		ColorShift_Top = Color3.fromRGB(151, 255, 229),
	}
end

return Zone
