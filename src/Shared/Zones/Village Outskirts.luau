local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Zone: Types.Zone = {
	Level = 1,
	MaxLevel = 1,
	Description = "A bilalge",
	Icon = "",
	Mobs = { "Wolf" },
}

return Zone
