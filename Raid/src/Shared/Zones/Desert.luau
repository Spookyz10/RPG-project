local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 7,
	MaxLevel = 27,
	Description = "",
	Icon = "rbxassetid://4755199680",
	Mobs = {},
	Order = 2,
	Theme = Color3.fromRGB(234, 255, 0),
}

function Zone.getLighting()
	return {
		TimeOfDay = "14:00:00",
		Ambient = Color3.fromRGB(188, 94, 0),
		OutdoorAmbient = Color3.fromRGB(236, 166, 167),
		ColorShift_Bottom = Color3.fromRGB(234, 0, 0),
		ColorShift_Top = Color3.fromRGB(255, 162, 32),
	}
end

return Zone
