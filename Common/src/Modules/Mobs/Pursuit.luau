-- Keep locomotion/spacing separate from attack selection.
local Pursuit = {}
Pursuit.__index = Pursuit

function Pursuit.new(mob, config)
	local root = mob:FindFirstChild("HumanoidRootPart")
	-- Use the locomotion body, not decorative meshes or legacy oversized hitboxes.
	local size = root.Size
	return setmetatable({
		Root = root,
		Humanoid = mob:FindFirstChildOfClass("Humanoid"),
		Config = config,
		Radius = config.BodyRadius or math.max(size.X, size.Z) * 0.5,
		Holding = false,
	}, Pursuit)
end

function Pursuit:Stop()
	self.Humanoid:Move(Vector3.zero)
	self.Humanoid:MoveTo(self.Root.Position)
	self.Humanoid.WalkSpeed = 0
	local velocity = self.Root.AssemblyLinearVelocity
	self.Root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
end

function Pursuit:Update(target)
	local root, hum, config = self.Root, self.Humanoid, self.Config
	local delta = (root.Position - target.Position) * Vector3.new(1, 0, 1)
	local distance = delta.Magnitude
	local direction = distance > 0.01 and delta.Unit or -root.CFrame.LookVector
	local targetRadius = math.max(target.Size.X, target.Size.Z) * 0.5
	local clearance = self.Radius + targetRadius + (config.SpacingBuffer or 1)
	local stopDistance = math.max(config.Range, clearance)
	local tolerance = config.SpacingTolerance or 0.5
	-- Back away if the player walks into the mob, rather than attacking from inside them.
	local tooClose = distance < clearance - tolerance
	self.TooClose = tooClose
	self.MeleeReach = stopDistance + tolerance
	local ready = not tooClose and distance <= stopDistance + (self.Holding and tolerance or 0)
	self.Holding = ready
	if ready then
		self:Stop()
		return true
	end
	local destination = target.Position + direction * stopDistance
	hum.AutoRotate = true
	hum.WalkSpeed = math.min(config.Speed, math.max(3, math.abs(distance - stopDistance) * 4))
	hum:MoveTo(Vector3.new(destination.X, root.Position.Y, destination.Z))
	return false
end

return Pursuit
