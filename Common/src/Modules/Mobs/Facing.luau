-- Rotate the server-owned assembly through physics without writing its position.
local Facing = {}
Facing.__index = Facing

function Facing.new(root, config)
	local attachment = Instance.new("Attachment")
	attachment.Name = "MobFacingAttachment"
	attachment.Parent = root
	local align = Instance.new("AlignOrientation")
	align.Name = "MobFacing"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = attachment
	align.RigidityEnabled = false
	align.Responsiveness = config.TurnResponsiveness or 18
	align.MaxAngularVelocity = config.TurnSpeed or math.rad(360)
	align.MaxTorque = 1e8
	align.Enabled = false
	align.Parent = root
	return setmetatable({ Root = root, Attachment = attachment, Align = align }, Facing)
end

function Facing:Towards(position)
	local delta = (position - self.Root.Position) * Vector3.new(1, 0, 1)
	if delta.Magnitude < 0.01 then return true end
	local direction = delta.Unit
	self.Align.CFrame = CFrame.lookAt(Vector3.zero, direction)
	self.Align.Enabled = true
	local look = self.Root.CFrame.LookVector * Vector3.new(1, 0, 1)
	return look.Magnitude > 0.01 and look.Unit:Dot(direction) >= math.cos(math.rad(8))
end

function Facing:Release()
	self.Align.Enabled = false
end

function Facing:Destroy()
	self.Align:Destroy()
	self.Attachment:Destroy()
end

return Facing
