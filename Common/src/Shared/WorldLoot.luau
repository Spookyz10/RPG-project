local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Items = require(RS.Shared.ItemsDataByName)
local Theme = require(RS.Shared.UI.Theme)
local UIFunctions = require(RS.Shared.UI.UIFunctions)
local Loot = {}
local active = {}
local function remove(index)
	active[index].Part:Destroy()
	table.remove(active, index)
end
function Loot.Play(items, origin)
	if not RunService:IsClient() then return end
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - origin).Magnitude > 240 then return end
	local names = {}
	for name, amount in items do
		if typeof(name) == "string" and typeof(amount) == "number" and amount > 0 then table.insert(names, name) end
	end
	table.sort(names)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excluded = {}
	for _, player in Players:GetPlayers() do if player.Character then table.insert(excluded, player.Character) end end
	local mobs = workspace:FindFirstChild("Mobs")
	if mobs then table.insert(excluded, mobs) end
	params.FilterDescendantsInstances = excluded
	for i, name in names do
		if #active >= 40 then remove(1) end
		local data = Items[name] and Items[name].Data or {}
		local angle = i / math.max(1, #names) * math.pi * 2
		local target = origin + Vector3.new(math.cos(angle) * 4, 0, math.sin(angle) * 4)
		local hit = workspace:Raycast(target + Vector3.new(0, 8, 0), Vector3.new(0, -60, 0), params)
		if not hit then continue end
		local part = Instance.new("Part")
		part.Name = "LocalLoot"
		part.Size = Vector3.new(0.65, 0.65, 0.65)
		part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
		part.Material = Enum.Material.Neon
		part.Color = Theme.Rarities[data.Rarity] or Theme.Gold
		part.Position = origin
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromScale(2.4, 2.4); billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.4, 0)
		billboard.AlwaysOnTop = false; billboard.MaxDistance = 100; billboard.Parent = part
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.fromScale(1, 1); icon.BackgroundTransparency = 1; icon.Parent = billboard
		local hasIcon = UIFunctions:SetIcon(icon, data.Icon)
		if not hasIcon then
			local fallback = Instance.new("TextLabel")
			fallback.Name = "ItemName"
			fallback.Size = UDim2.fromScale(1, 1)
			fallback.BackgroundTransparency = 1
			fallback.Font = Enum.Font.GothamBold
			fallback.Text = data.Name or name
			fallback.TextColor3 = Color3.new(1, 1, 1)
			fallback.TextScaled = true
			fallback.TextStrokeTransparency = 0
			fallback.TextWrapped = true
			fallback.Parent = billboard
		end
		local a = Instance.new("Attachment"); a.Position = Vector3.new(-0.15, 0, 0); a.Parent = part
		local b = Instance.new("Attachment"); b.Position = Vector3.new(0.15, 0, 0); b.Parent = part
		local trail = Instance.new("Trail")
		trail.Attachment0 = a; trail.Attachment1 = b; trail.Lifetime = 0.15
		trail.Color = ColorSequence.new(part.Color); trail.Transparency = NumberSequence.new(0.2, 1); trail.Parent = part
		part.Parent = workspace
		table.insert(active, {Part = part, Start = origin, Floor = hit.Position + Vector3.new(0, 0.5, 0), Started = os.clock(), Character = character, Delay = (i % 5) * 0.06})
	end
end
if RunService:IsClient() then
	RunService.RenderStepped:Connect(function()
		for i = #active, 1, -1 do
			local entry = active[i]
			local t = os.clock() - entry.Started - entry.Delay
			local root = entry.Character:FindFirstChild("HumanoidRootPart")
			local hum = entry.Character:FindFirstChildOfClass("Humanoid")
			if not entry.Part.Parent or Players.LocalPlayer.Character ~= entry.Character or not root or not hum or hum.Health <= 0 or t >= 1.65 then
				remove(i); continue
			end
			local position
			if t < 0.55 then
				local alpha = math.clamp(t / 0.55, 0, 1)
				position = entry.Start:Lerp(entry.Floor, alpha) + Vector3.new(0, math.sin(alpha * math.pi) * 4, 0)
			elseif t < 0.95 then
				position = entry.Floor + Vector3.new(0, math.abs(math.sin((t - 0.55) / 0.4 * math.pi * 2)) * (0.95 - t) * 2, 0)
			else
				local alpha = math.clamp((t - 0.95) / 0.7, 0, 1)
				position = entry.Floor:Lerp(root.Position, alpha * alpha) + Vector3.new(0, math.sin(alpha * math.pi) * 2, 0)
				entry.Part.Size = Vector3.one * (0.65 * (1 - alpha) + 0.05)
			end
			entry.Part.CFrame = CFrame.new(position) * CFrame.Angles(t * 2, t * 4, 0)
		end
	end)
end
return Loot
