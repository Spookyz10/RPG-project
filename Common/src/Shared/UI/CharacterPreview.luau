local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(script.Parent.Parent.Utils.Functions)
local Items = require(script.Parent.Parent.ItemsData)
local Preview = {}

local function clean(model)
	for _, object in model:GetDescendants() do
		if object:IsA("LuaSourceContainer") or object:IsA("LayerCollector") or object:IsA("Sound") or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object.Name == "Hitbox" then
			object:Destroy()
		elseif object:IsA("BasePart") then
			object.Anchored = object.Name == "HumanoidRootPart"
			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Massless = true
		end
	end
end

function Preview.Bind(root, data)
	local player = Players.LocalPlayer
	local userId = player.UserId
	local hero = root.Body.Content.Hero
	local viewport = hero.CharacterPreview
	local camera = viewport:FindFirstChildOfClass("Camera") or Instance.new("Camera")
	camera.Name = "PreviewCamera"
	camera.FieldOfView = 32
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	-- This user model stays cached in the WorldModel until the UI is destroyed.
	local model, idle, weaponKey, idleKey, bodyBounds, bodySize
	local loading, queued, destroyed = false, false, false
	local connections = {}
	local function fit()
		if not model or not bodyBounds then return end
		local aspect = math.max(0.25, viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y))
		local tangent = math.tan(math.rad(camera.FieldOfView / 2))
		local distance = math.max(bodySize.Y * 0.5 / tangent, bodySize.X * 0.5 / (tangent * aspect)) + bodySize.Z * 0.5
		local center = bodyBounds.Position
		-- Fit the avatar, not the sword's potentially oversized bounds.
		camera.CFrame = CFrame.lookAt(center + Vector3.new(0, 0, distance * 0.94), center)
	end
	local function stats()
		local values = Functions:GetTotalStats(player.Character, data()) or {}
		for _, row in hero.Stats:GetChildren() do
			if row:IsA("Frame") and row:FindFirstChild("Value") then
				row.Value.Text = string.format("%.1f", values[row.Name] or 0):gsub("%.0$", "") .. (row.Name == "Critical" and "%" or "")
			end
		end
	end
	local function updateWeapon()
		local equipped = data.Equipment.Weapon()
		local entry = equipped and data.Inventory[equipped]()
		local vanity = data.Vanity.Weapon()
		local appearance = entry and ((vanity and vanity ~= "" and data.Inventory[vanity]()) or entry)
		local name = appearance and appearance.Name or ""
		if weaponKey ~= name then
			local old = model:FindFirstChild("Sword")
			if old then old:Destroy() end
			weaponKey = name
			local hand = model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
			local template = ReplicatedStorage.Resources.Weapons:FindFirstChild(name, true)
			if hand and template and template:IsA("Model") then
				local sword = template:Clone()
				clean(sword)
				local handle = sword:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					sword.Name = "Sword"
					sword.PrimaryPart = handle
					local grip = handle:FindFirstChild("GripPoint")
					sword:PivotTo(hand.CFrame * (grip and grip.CFrame:Inverse() or CFrame.new()) * CFrame.Angles(math.rad(190), math.rad(-180), 0))
					for _, part in sword:GetDescendants() do
						if part:IsA("BasePart") then
							local weld = Instance.new("WeldConstraint")
							weld.Part0 = part == handle and hand or handle
							weld.Part1 = part
							weld.Parent = part
						end
					end
					sword.Parent = model
				else sword:Destroy() end
			end
		end
		local info = entry and (Items[entry.ID] or Items[entry.Name])
		local weaponType = info and info.WeaponType or ""
		if idleKey ~= weaponType then
			if idle then idle:Stop(0.15); idle:Destroy(); idle = nil end
			idleKey = weaponType
			local animation = ReplicatedStorage.Resources.Animations:FindFirstChild(weaponType, true)
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if animation and animation:IsA("Animation") and humanoid then
				local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
				animator.Parent = humanoid
				local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
				if ok then
					idle = track
					idle.Looped = true
					idle.Priority = Enum.AnimationPriority.Idle
					idle:Play(0.15)
				end
			end
		end
	end
	local function refresh()
		if destroyed or not root.Visible or not hero.Visible then return end
		stats()
		if loading then return end
		if not model then
			loading = true
			viewport.Status.Visible = true
			local ok, avatar = pcall(function()
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					-- Match the game's rig so its weapon idles use the correct joints.
					local description = Players:GetHumanoidDescriptionFromUserIdAsync(userId)
					local built, result = pcall(function()
						return Players:CreateHumanoidModelFromDescriptionAsync(description, humanoid.RigType)
					end)
					description:Destroy()
					if not built then error(result) end
					return result
				end
				return Players:CreateHumanoidModelFromUserIdAsync(userId)
			end)
			loading = false
			if destroyed then if ok then avatar:Destroy() end; return end
			if not ok then viewport.Status.Text = "Hero preview unavailable"; return end
			clean(avatar)
			avatar.Name = "HeroPreview"
			avatar:PivotTo(CFrame.Angles(0, math.pi, 0))
			model = avatar
			model.Parent = viewport.World
			bodyBounds, bodySize = model:GetBoundingBox()
			fit()
		end
		viewport.Status.Visible = false
		updateWeapon()
		if idle then idle:AdjustSpeed(root.Visible and hero.Visible and 1 or 0) end
	end
	local function schedule()
		if destroyed or queued then return end
		queued = true
		task.delay(0.15, function() queued = false; if not destroyed then refresh() end end)
	end
	local function visibility()
		if idle then idle:AdjustSpeed(root.Visible and hero.Visible and 1 or 0) end
		schedule()
	end
	table.insert(connections, root:GetPropertyChangedSignal("Visible"):Connect(visibility))
	table.insert(connections, hero:GetPropertyChangedSignal("Visible"):Connect(visibility))
	table.insert(connections, viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
	table.insert(connections, player.CharacterAdded:Connect(schedule))
	for _, key in { "Equipment", "Vanity", "ExtraStats", "Level", "Inventory" } do
		local connection = data[key].Changed(schedule)
		if connection then table.insert(connections, connection) end
	end
	schedule()
	root.Destroying:Connect(function()
		destroyed = true
		for _, connection in connections do connection:Disconnect() end
		if idle then idle:Stop(); idle:Destroy() end
		if model then model:Destroy() end
	end)
end

return Preview
