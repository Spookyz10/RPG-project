local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = {}

local EffectsFolder = ReplicatedStorage.Resources.Effects.Cyclone

local GROWTH_STEP = Vector3.new(0.7, 0.6, 0.7)
local GROWTH_ITERATIONS = 10

local function getOrCreateBladeAttachments(Handle: BasePart): (Attachment, Attachment)
	local Top = Handle:FindFirstChild("CycloneTrailTop") :: Attachment?
	local Bottom = Handle:FindFirstChild("CycloneTrailBottom") :: Attachment?

	if Top and Bottom then
		return Top, Bottom
	end

	local HalfHeight = Handle.Size.Y / 2

	Top = Instance.new("Attachment")
	Top.Name = "CycloneTrailTop"
	Top.Position = Vector3.new(0, HalfHeight, 0)
	Top.Parent = Handle

	Bottom = Instance.new("Attachment")
	Bottom.Name = "CycloneTrailBottom"
	Bottom.Position = Vector3.new(0, -HalfHeight, 0)
	Bottom.Parent = Handle

	return Top, Bottom
end

function VFX:Play(Character: Model)
	local Sword = Character:FindFirstChild("Sword") :: Model?
	local RootPart = Character.PrimaryPart
	local UpperTorso = Character:FindFirstChild("UpperTorso")

	if not RootPart or not UpperTorso then
		return
	end

	local Handle = Sword and (Sword.PrimaryPart or Sword:FindFirstChild("Handle") :: BasePart?)

	if Handle then
		local AttachmentTop, AttachmentBottom = getOrCreateBladeAttachments(Handle)

		local Trail1 = EffectsFolder.Cyclone1:Clone()
		Trail1.Parent = Handle
		Trail1.Attachment0 = AttachmentTop
		Trail1.Attachment1 = AttachmentBottom
		Debris:AddItem(Trail1, 0.9)

		local Trail2 = EffectsFolder.Cyclone2:Clone()
		Trail2.Parent = Handle
		Trail2.Attachment0 = AttachmentTop
		Trail2.Attachment1 = AttachmentBottom
		Debris:AddItem(Trail2, 0.9)
	end

	local Wind1 = EffectsFolder.CycloneWind:Clone()
	Wind1.Parent = RootPart
	Wind1.Weld.Part0 = UpperTorso
	Debris:AddItem(Wind1, 0.7)

	local Wind2 = EffectsFolder.CycloneWind2:Clone()
	Wind2.Parent = RootPart
	Wind2.Weld.Part0 = UpperTorso

	local Wind3 = EffectsFolder.CycloneWind3:Clone()
	Wind3.Parent = RootPart
	Wind3.Weld.Part0 = UpperTorso
	Debris:AddItem(Wind3, 0.7)

	task.delay(0.6, function()
		if not Wind2 or not Wind2.Parent then
			return
		end

		for _ = 1, GROWTH_ITERATIONS do
			if not Wind2 or not Wind2.Parent then
				return
			end

			Wind2.Transparency += 0.05
			Wind2.Orientation = Vector3.new(0, Wind2.Orientation.Y, 0)
			Wind2.Mesh.Scale += GROWTH_STEP
			task.wait(0.02)
		end

		Debris:AddItem(Wind2, 0)
	end)
end

return VFX
