local Players = game:GetService("Players")
local Functions = require(script.Parent.Parent.Utils.Functions)
local Preview = {}

function Preview.Bind(root, data)
	local player = Players.LocalPlayer
	local hero = root.Body.Content.Hero
	local viewport = hero.CharacterPreview
	local world = viewport.World
	-- Camera references are not replicated. Bind/create the local rendering camera.
	local camera = viewport:FindFirstChildOfClass("Camera") or Instance.new("Camera")
	camera.Name = "PreviewCamera"
	camera.FieldOfView = 38
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local model
	local queued = false
	local destroyed = false
	local characterConnections = {}
	local connections = {}
	local function fit()
		if not model then return end
		local bounds, size = model:GetBoundingBox()
		local aspect = math.max(0.25, viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y))
		local halfFov = math.rad(camera.FieldOfView / 2)
		local distance = math.max(size.Y / 2 / math.tan(halfFov), size.X / 2 / (math.tan(halfFov) * aspect)) + size.Z / 2
		local center = bounds.Position
		camera.CFrame = CFrame.lookAt(center + Vector3.new(0, size.Y * 0.03, distance * 1.12), center)
	end
	local function stats()
		local values = Functions:GetTotalStats(player.Character, data()) or {}
		for _, row in hero.Stats:GetChildren() do
			if row:IsA("Frame") and row:FindFirstChild("Value") then
				row.Value.Text = string.format("%.1f", values[row.Name] or 0):gsub("%.0$", "") .. (row.Name == "Critical" and "%" or "")
			end
		end
	end
	local function rebuild()
		if destroyed or not root.Visible or not hero.Visible then return end
		stats()
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then viewport.Status.Visible = true; return end
		local archivable = character.Archivable
		character.Archivable = true
		local ok, clone = pcall(function() return character:Clone() end)
		character.Archivable = archivable
		if not ok or not clone then viewport.Status.Text = "Hero preview unavailable"; viewport.Status.Visible = true; return end
		for _, object in clone:GetDescendants() do
			if object:IsA("LuaSourceContainer") or object:IsA("LayerCollector") or object:IsA("Sound") or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object.Name == "Hitbox" then
				object:Destroy()
			elseif object:IsA("BasePart") then
				object.Anchored = true
				object.CanCollide = false
				object.CanTouch = false
				object.CanQuery = false
				object.LocalTransparencyModifier = 0
			end
		end
		clone.Name = "HeroPreview"
		clone:PivotTo(CFrame.Angles(0, math.rad(165), 0))
		if model then model:Destroy() end
		model = clone
		model.Parent = world
		viewport.Status.Visible = false
		fit()
	end
	local function schedule()
		if destroyed or queued then return end
		queued = true
		task.delay(0.15, function() queued = false; if not destroyed then rebuild() end end)
	end
	local function bindCharacter(character)
		for _, connection in characterConnections do connection:Disconnect() end
		table.clear(characterConnections)
		for _, event in { character.DescendantAdded, character.DescendantRemoving } do
			table.insert(characterConnections, event:Connect(function(object)
				if object:IsA("BasePart") or object:IsA("Accessory") or object:IsA("Clothing") or object:IsA("Model") then schedule() end
			end))
		end
		schedule()
	end
	table.insert(connections, root:GetPropertyChangedSignal("Visible"):Connect(function()
		if root.Visible then schedule() elseif model then model:Destroy(); model = nil end
	end))
	table.insert(connections, hero:GetPropertyChangedSignal("Visible"):Connect(schedule))
	table.insert(connections, viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
	table.insert(connections, player.CharacterAdded:Connect(bindCharacter))
	table.insert(connections, player.CharacterAppearanceLoaded:Connect(schedule))
	for _, key in { "Equipment", "Vanity", "ExtraStats", "Level", "Inventory" } do
		local connection = data[key].Changed(schedule)
		if connection then table.insert(connections, connection) end
	end
	if player.Character then bindCharacter(player.Character) end
	root.Destroying:Connect(function()
		destroyed = true
		for _, connection in connections do connection:Disconnect() end
		for _, connection in characterConnections do connection:Disconnect() end
	end)
end

return Preview
