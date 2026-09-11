local Players = game:GetService("Players")
local cooldown = {}
local connections = {}

local function bind(part)
	if not part:IsA("BasePart") or connections[part] then return end
	connections[part] = part.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not player or not humanoid or humanoid.Health <= 0 or (cooldown[player] or 0) > os.clock() then return end
		local destinations = workspace:FindFirstChild("ZoneTeleportes") or workspace:FindFirstChild("ZoneTeleporters")
		local name = part:GetAttribute("Destination")
		local target = typeof(name) == "string" and destinations and destinations:FindFirstChild(name)
		if not target or not target:IsA("BasePart") then return end
		cooldown[player] = os.clock() + 2
		character:PivotTo(target.CFrame + Vector3.new(0, 3, 0))
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
	end)
	part.Destroying:Once(function() connections[part]:Disconnect(); connections[part] = nil end)
end
local function bindFolder(folder)
	if folder.Name ~= "ZonePortals" then return end
	for _, part in folder:GetDescendants() do bind(part) end
	folder.DescendantAdded:Connect(bind)
end
for _, folder in workspace:GetChildren() do bindFolder(folder) end
workspace.ChildAdded:Connect(bindFolder)
Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
