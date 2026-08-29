local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = {}

local EffectsFolder = ReplicatedStorage.Resources.Effects["Lure Jab"]

local SPIN_ITERATIONS = 12
local SPIN_STEP = math.rad(36)

local function getOrCreateBladeAttachments(Handle: BasePart): (Attachment, Attachment)
	local Top = Handle:FindFirstChild("LureTrailTop") :: Attachment?
	local Bottom = Handle:FindFirstChild("LureTrailBottom") :: Attachment?

	if Top and Bottom then
		return Top, Bottom
	end

	local HalfHeight = Handle.Size.Y / 2

	Top = Instance.new("Attachment")
	Top.Name = "LureTrailTop"
	Top.Position = Vector3.new(0, HalfHeight, 0)
	Top.Parent = Handle

	Bottom = Instance.new("Attachment")
	Bottom.Name = "LureTrailBottom"
	Bottom.Position = Vector3.new(0, -HalfHeight, 0)
	Bottom.Parent = Handle

	return Top, Bottom
end

function VFX:Play(Character: Model)
	local Sword = Character:FindFirstChild("Sword") :: Model?
	local RootPart = Character.PrimaryPart

	if not Sword or not RootPart then
		return
	end

	local Handle = Sword.PrimaryPart or (Sword:FindFirstChild("Handle") :: BasePart?)

	local Trail = EffectsFolder.LureTrail:Clone()
	Trail.Parent = Sword

	if Handle then
		local AttachmentTop, AttachmentBottom = getOrCreateBladeAttachments(Handle)
		Trail.Attachment0 = AttachmentTop
		Trail.Attachment1 = AttachmentBottom
	end

	Debris:AddItem(Trail, 0.3)

	local Ring = EffectsFolder.Lure:Clone()
	Ring.Parent = Sword
	Ring.Anchored = true
	Ring.CanCollide = false
	Ring.CFrame = RootPart.CFrame

	task.spawn(function()
		for i = 1, SPIN_ITERATIONS do
			if not Ring.Parent then
				break
			end

			Ring.CFrame = Ring.CFrame * CFrame.Angles(0, SPIN_STEP, 0)
			Ring.Transparency = i / SPIN_ITERATIONS
			task.wait()
		end

		if Ring.Parent then
			Ring:Destroy()
		end
	end)
end

return VFX
