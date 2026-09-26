local Players = game:GetService("Players")
local Resources = game:GetService("ReplicatedStorage"):WaitForChild("Resources")
local Motion = require(game:GetService("ReplicatedStorage").Shared.MobAnimations)
local library = Resources:WaitForChild("Animations", 10)
assert(library, "Install client animation assets before running")

local function bind(character)
	local hum = character:WaitForChild("Humanoid", 10)
	if not hum or not character.Parent then return end
	local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 10)
	if not animator or not character:IsDescendantOf(workspace) then return end
	local tracks, connections = {}, {}
	local current, currentName
	local speed = 0
	local destroyed = false
	local function load(name, id, looped)
		local source = library:FindFirstChild(name, true)
		local animation = source or Instance.new("Animation")
		if not source then animation.AnimationId = "rbxassetid://" .. id end
		local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
		if not source then animation:Destroy() end
		if ok then
			track.Looped = looped
			track.Priority = Enum.AnimationPriority.Movement
			tracks[name] = track
		else
			warn("[PlayerAnimations] " .. name .. ": " .. tostring(track))
		end
	end
	-- Only the owning client starts locomotion tracks; Roblox replicates them to observers.
	load("Idle", "180435571", true)
	load("PlayerRun", "180426354", true)
	load("Solo", "180435571", true)
	load("Jump", "125750702", false)
	load("Fall", "180436148", true)
	load("Climb", "180436334", true)
	load("Sit", "178130996", true)
	local function refresh()
		if destroyed then return end
		local state = hum:GetState()
		local name
		if hum.Health > 0 and not character:GetAttribute("ClientMotion") then
			if state == Enum.HumanoidStateType.Jumping then name = "Jump"
			elseif state == Enum.HumanoidStateType.Freefall then name = "Fall"
			elseif state == Enum.HumanoidStateType.Climbing then name = "Climb"
			elseif state == Enum.HumanoidStateType.Seated then name = "Sit"
			elseif state ~= Enum.HumanoidStateType.Physics and state ~= Enum.HumanoidStateType.PlatformStanding then
				name = speed > 0.5 and "PlayerRun" or character:GetAttribute("WeaponStyle") == "Solo" and "Solo" or "Idle"
			end
		end
		if name ~= currentName then
			if current then current:Stop(character:GetAttribute("ClientMotion") and 0 or 0.12) end
			currentName, current = name, name and tracks[name]
			if current then current:Play(0.12) end
		end
		if current and name == "PlayerRun" then current:AdjustSpeed(math.max(0.1, speed / 16)) end
		if current and name == "Climb" then current:AdjustSpeed(speed / 12) end
	end
	local function disable(object)
		if object.Name == "Animate" and object:IsA("LocalScript") then object.Enabled = false end
	end
	for _, object in character:GetChildren() do disable(object) end
	for _, track in animator:GetPlayingAnimationTracks() do track:Stop(0) end
	table.insert(connections, character.ChildAdded:Connect(disable))
	table.insert(connections, hum.Running:Connect(function(value) speed = value; refresh() end))
	table.insert(connections, hum.Swimming:Connect(function(value) speed = value; refresh() end))
	table.insert(connections, hum.Climbing:Connect(function(value) speed = math.abs(value); refresh() end))
	table.insert(connections, hum.StateChanged:Connect(refresh))
	table.insert(connections, character:GetAttributeChangedSignal("ClientMotion"):Connect(refresh))
	table.insert(connections, character:GetAttributeChangedSignal("WeaponStyle"):Connect(refresh))
	local function cleanup()
		if destroyed then return end
		destroyed = true
		Motion:Detach(character)
		for _, connection in connections do connection:Disconnect() end
		for _, track in tracks do track:Stop(0); track:Destroy() end
	end
	table.insert(connections, hum.Died:Connect(cleanup))
	table.insert(connections, character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(workspace) then cleanup() end
	end))
	refresh()
end
local player = Players.LocalPlayer
player.CharacterAdded:Connect(bind)
if player.Character then task.spawn(bind, player.Character) end
