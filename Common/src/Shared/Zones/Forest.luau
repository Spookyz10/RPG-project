local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

-- Zone discovery is driven by this module's location and name. The selector reads
-- every module below Shared.Zones and, with Mobs empty, discovers its roster from
-- the matching MobsData folder.
local Zone: Types.Zone = {
	Level = 16,
	MaxLevel = 25,
	Description = "Follow winding trails beneath an ancient canopy, uncover the ruins, and challenge Elderbark in the Heartgrove.",
	Icon = "",
	Mobs = {},
	Order = 2,
	Theme = Color3.fromRGB(109, 187, 147),
}

function Zone.getLighting()
	local resources = ReplicatedStorage:FindFirstChild("Resources")
	local templates = resources and resources:FindFirstChild("LightingTemplates")
	local template = templates and templates:FindFirstChild(script.Name)
	return template and template:GetAttributes() or {}
end

return Zone
