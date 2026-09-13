local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ViewportCache = {}
local avatarTemplates: { [string]: Model } = {}
local pending: { [string]: BindableEvent } = {}
local weaponTemplates: { [string]: Model } = {}
local modelTemplates: { [Model]: Model } = {}
setmetatable(modelTemplates, { __mode = "k" })

local function sanitize(model: Model, anchorAll: boolean?)
	for _, object in model:GetDescendants() do
		if object:IsA("LuaSourceContainer") or object:IsA("LayerCollector") or object:IsA("Sound") or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object.Name == "Hitbox" then
			object:Destroy()
		elseif object:IsA("BasePart") then
			object.Anchored = anchorAll == true or object.Name == "HumanoidRootPart"
			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Massless = true
		end
	end
end

local function rigTypeFor(player: Player): Enum.HumanoidRigType
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.RigType or Enum.HumanoidRigType.R6
end

function ViewportCache.EnsureViewport(viewport: ViewportFrame, cameraName: string, fieldOfView: number?): (WorldModel, Camera)
	local world = viewport:FindFirstChild("World")
	if not world or not world:IsA("WorldModel") then
		if world then world:Destroy() end
		world = Instance.new("WorldModel")
		world.Name = "World"
		world.Parent = viewport
	end
	local camera = viewport:FindFirstChild(cameraName)
	if not camera or not camera:IsA("Camera") then
		if camera then camera:Destroy() end
		camera = Instance.new("Camera")
		camera.Name = cameraName
		camera.Parent = viewport
	end
	if fieldOfView then camera.FieldOfView = fieldOfView end
	viewport.CurrentCamera = camera
	return world, camera
end

function ViewportCache.GetPlayerModel(player: Player): Model?
	local rigType = rigTypeFor(player)
	local key = tostring(player.UserId) .. ":" .. rigType.Name
	local cached = avatarTemplates[key]
	if cached then
		return cached:Clone()
	end
	local loading = pending[key]
	if loading then
		loading.Event:Wait()
		cached = avatarTemplates[key]
		return cached and cached:Clone() or nil
	end
	loading = Instance.new("BindableEvent")
	pending[key] = loading
	local ok, result = pcall(function()
		local description = Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
		local built, model = pcall(function()
			return Players:CreateHumanoidModelFromDescriptionAsync(description, rigType)
		end)
		description:Destroy()
		if not built then error(model) end
		return model
	end)
	if ok and player.Parent then
		local model = result :: Model
		sanitize(model)
		model.Name = "ViewportAvatar"
		model:PivotTo(CFrame.Angles(0, math.pi, 0))
		avatarTemplates[key] = model
	elseif ok then
		(result :: Model):Destroy()
		ok = false
	end
	pending[key] = nil
	loading:Fire()
	loading:Destroy()
	return ok and (result :: Model):Clone() or nil
end

function ViewportCache.GetModel(source: Model): Model
	local cached = modelTemplates[source]
	if not cached then
		cached = source:Clone()
		sanitize(cached, true)
		cached:PivotTo(CFrame.identity)
		modelTemplates[source] = cached
	end
	return cached:Clone()
end

local function findWeapon(name: string): Model?
	local cached = weaponTemplates[name]
	if cached and cached.Parent then return cached end
	local folder = ReplicatedStorage.Resources:FindFirstChild("Weapons")
	if not folder then
		return nil
	end
	for _, object in folder:GetDescendants() do
		if object:IsA("Model") and object.Name == name then
			weaponTemplates[name] = object
			return object
		end
	end
	return nil
end

local function getHand(character: Model, side: "Right" | "Left"): BasePart?
	local hand = character:FindFirstChild(side .. "Hand") or character:FindFirstChild(side .. " Arm")
	return hand and hand:IsA("BasePart") and hand or nil
end

local function attachWeapon(character: Model, template: Model, hand: BasePart, modelName: string): Model?
	local weapon = template:Clone()
	weapon.Name = modelName
	local handle = weapon:FindFirstChild("Handle", true)
	if not handle or not handle:IsA("BasePart") then
		weapon:Destroy()
		return nil
	end
	sanitize(weapon)
	weapon.PrimaryPart = handle
	weapon.Parent = character
	local position = weapon:GetAttribute("GripPosition")
	local orientation = weapon:GetAttribute("GripOrientation")
	if typeof(position) ~= "Vector3" then position = Vector3.new(0, -1, 0) end
	if typeof(orientation) ~= "Vector3" then orientation = Vector3.zero end
	local gripPoint = handle:FindFirstChild("GripPoint")
	local c1 = gripPoint and gripPoint:IsA("Attachment") and gripPoint.CFrame or CFrame.identity
	local c0 = CFrame.new(position) * CFrame.fromOrientation(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z))
	weapon:PivotTo(hand.CFrame * c0 * c1:Inverse())
	local grip = Instance.new("Weld")
	grip.Name = "WeaponGrip"
	grip.Part0 = hand
	grip.Part1 = handle
	grip.C0 = c0
	grip.C1 = c1
	grip.Parent = handle
	for _, part in weapon:GetDescendants() do
		if part:IsA("BasePart") and part ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = part
			weld.Parent = part
		end
	end
	return weapon
end

function ViewportCache.AttachWeapon(character: Model, weaponName: string?, weaponType: string?): Model?
	for _, modelName in { "Sword", "OffhandSword" } do
		local existing = character:FindFirstChild(modelName)
		if existing then
			existing:Destroy()
		end
	end
	if not weaponName or weaponName == "" then
		return nil
	end
	local template = findWeapon(weaponName)
	local rightHand = getHand(character, "Right")
	if not template or not rightHand then
		return nil
	end
	local rightWeapon = attachWeapon(character, template, rightHand, "Sword")
	if weaponType == "Dual" then
		local leftHand = getHand(character, "Left")
		if leftHand then
			attachWeapon(character, template, leftHand, "OffhandSword")
		end
	end
	return rightWeapon
end

local function playIdleTrack(humanoid: Humanoid, animation: Animation, priority: Enum.AnimationPriority): AnimationTrack?
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
	if not ok then return nil end
	track.Looped = true
	track.Priority = priority
	track:Play(0.15)
	return track
end

function ViewportCache.PlayDefaultIdle(character: Model, priority: Enum.AnimationPriority?): AnimationTrack?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local animation = Instance.new("Animation")
	animation.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R6 and "rbxassetid://180435571" or "rbxassetid://507766388"
	local track = playIdleTrack(humanoid, animation, priority or Enum.AnimationPriority.Core)
	animation:Destroy()
	return track
end

function ViewportCache.PlayIdle(character: Model, weaponType: string?, allowDefaultFallback: boolean?): AnimationTrack?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local animation = weaponType and ReplicatedStorage.Resources.Animations:FindFirstChild(weaponType, true)
	if not animation or not animation:IsA("Animation") then
		return allowDefaultFallback == false and nil or ViewportCache.PlayDefaultIdle(character, Enum.AnimationPriority.Idle)
	end
	return playIdleTrack(humanoid, animation, Enum.AnimationPriority.Idle)
end

function ViewportCache.Fit(
	viewport: ViewportFrame,
	model: Model,
	camera: Camera,
	scale: number?,
	savedBounds: CFrame?,
	savedSize: Vector3?,
	direction: Vector3?
)
	local bounds, size
	if savedBounds and savedSize then
		bounds, size = savedBounds, savedSize
	else
		bounds, size = model:GetBoundingBox()
	end
	local aspect = math.max(0.25, viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y))
	local tangent = math.tan(math.rad(camera.FieldOfView / 2))
	local distance = math.max(size.Y * 0.5 / tangent, size.X * 0.5 / (tangent * aspect)) + size.Z * 0.5
	local viewDirection = direction and direction.Magnitude > 0 and direction.Unit or Vector3.new(0, 0, 1)
	camera.CFrame = CFrame.lookAt(bounds.Position + viewDirection * distance * (scale or 1), bounds.Position)
end

Players.PlayerRemoving:Connect(function(player)
	local prefix = tostring(player.UserId) .. ":"
	for key, model in avatarTemplates do
		if string.sub(key, 1, #prefix) == prefix then
			model:Destroy()
			avatarTemplates[key] = nil
		end
	end
end)

return ViewportCache
