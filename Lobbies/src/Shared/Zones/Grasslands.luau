local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 1,
	MaxLevel = 15,
	Description = "",
	Icon = "rbxassetid://4755207177",
	Mobs = {},
	Order = 1,
	Theme = Color3.fromRGB(17, 255, 0),
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
