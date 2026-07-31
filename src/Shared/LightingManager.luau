local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Zones = require(script.Parent.Zones)
local LightingManager = {}

local LightingPresets = ReplicatedStorage:WaitForChild("Assets"):FindFirstChild("Lighting")

local function getPresetFolder(name: string)
	for _, preset in LightingPresets:GetDescendants() do
		if preset:IsA("Folder") and preset.Name == name then
			return preset
		end
	end

	return nil
end

function LightingManager:ApplyZoneLighting(zoneName: string)
	local ZoneInfo = Zones[zoneName] :: Types.Zone

	if not ZoneInfo then
		return
	end

	local Preset = getPresetFolder(zoneName)
	if not Preset then
		return
	end

	for _, propety in Lighting:GetChildren() do
		propety:Destroy()
	end

	for _, lightingEffect in Preset:GetChildren() do
		lightingEffect:Clone().Parent = Lighting
	end

	for propety, value in ZoneInfo.getLighting() do
		if Lighting[propety] then
			Lighting[propety] = value
		end
	end
end

return LightingManager
