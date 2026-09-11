local RS = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local manager = require(RS.Shared.LightingManager)
local grasslands = require(RS.Shared.Zones.Grasslands)
local inside = false
while true do
	local regions = workspace:FindFirstChild("ZoneRegions")
	local region = regions and regions:FindFirstChild("DireBearCave")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local current = false
	if region and root then
		local p = region.CFrame:PointToObjectSpace(root.Position)
		local half = region.Size / 2
		current = math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y and math.abs(p.Z) <= half.Z
	end
	if current ~= inside then
		inside = current
		if inside then
			manager:Apply("DireBearCave", {ClockTime = 0, Brightness = 1, Ambient = Color3.fromRGB(55, 65, 80), OutdoorAmbient = Color3.fromRGB(35, 42, 55), FogColor = Color3.fromRGB(25, 34, 42), FogStart = 80, FogEnd = 330})
		else
			manager:ResetToDefault()
			manager:Apply("Grasslands", grasslands.getLighting())
		end
	end
	task.wait(0.15)
end
