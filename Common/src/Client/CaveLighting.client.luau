-- A named ZoneRegion automatically uses a same-named LightingTemplate. Special
-- regions without a template can still provide a local property table below.
local RS = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local manager = require(RS.Shared.LightingManager)
local activeRegion = nil
local function contains(region, position)
	if not region or not region:IsA("BasePart") then
		return false
	end
	local p = region.CFrame:PointToObjectSpace(position)
	local half = region.Size / 2
	return math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y and math.abs(p.Z) <= half.Z
end
while true do
	local regions = workspace:FindFirstChild("ZoneRegions")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local resources = RS:FindFirstChild("Resources")
	local templates = resources and resources:FindFirstChild("LightingTemplates")
	local current = nil
	if root and regions then
		for _, region in regions:GetChildren() do
			if contains(region, root.Position) then
				local hasTemplate = templates and templates:FindFirstChild(region.Name)
				if hasTemplate or region.Name == "Dire Bear Cave" then
					current = region.Name
					break
				end
			end
		end
	end
	if current ~= activeRegion then
		activeRegion = current
		manager:ResetToDefault()
		local template = current and templates and templates:FindFirstChild(current)
		if template then
			manager:Apply(current, template:GetAttributes())
		elseif current == "Dire Bear Cave" then
			manager:Apply("Dire Bear Cave", {
				ClockTime = 0,
				Brightness = 1,
				Ambient = Color3.fromRGB(55, 65, 80),
				OutdoorAmbient = Color3.fromRGB(35, 42, 55),
				FogColor = Color3.fromRGB(25, 34, 42),
				FogStart = 80,
				FogEnd = 330,
			})
		end
	end
	task.wait(0.15)
end
