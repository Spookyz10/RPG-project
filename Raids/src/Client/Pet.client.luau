local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)

local EffectsFolder = ReplicatedStorage.Resources.Effects.Pets
local PetsFolder = workspace:WaitForChild("Pets")

local MOVING_ANIMATIONS = { "PetIdle", "PetWalk" }

local ActiveTalentEffects: { [Model]: Instance } = {}

local function SetAnimation(petModel: Model, animName: string)
	local Handler = AnimationHandler.GetOrCreate(petModel)

	task.spawn(function()
		local NewTrack = Handler:Play(animName, 0.15)
		if not NewTrack then
			return
		end

		NewTrack.Looped = true

		for _, otherName in MOVING_ANIMATIONS do
			if otherName ~= animName then
				Handler:Stop(otherName, 0.15)
			end
		end
	end)
end

local function UpdateMoving(petModel: Model)
	local IsMoving = petModel:GetAttribute("Moving") == true
	SetAnimation(petModel, IsMoving and "PetWalk" or "PetIdle")
end

local function GetAttachTarget(petModel: Model, bodyPartName: string?): Instance?
	if bodyPartName and bodyPartName ~= "" then
		local Target = petModel:FindFirstChild(bodyPartName)
		if Target then
			return Target
		end
	end

	return petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Base")
end

local function ApplyTalentEffect(petModel: Model)
	local Existing = ActiveTalentEffects[petModel]
	if Existing then
		Existing:Destroy()
		ActiveTalentEffects[petModel] = nil
	end

	local TalentName = petModel:GetAttribute("Talent")
	if typeof(TalentName) ~= "string" or TalentName == "" then
		return
	end

	local TalentFolder = EffectsFolder:FindFirstChild(TalentName)
	if not TalentFolder then
		return
	end

	local AttachmentTemplate = TalentFolder:FindFirstChild("Attachment") :: Attachment?
	if not AttachmentTemplate then
		return
	end

	local BodyPartValue = TalentFolder:FindFirstChild("BodyPart") :: StringValue?
	local AttachTarget = GetAttachTarget(petModel, BodyPartValue and BodyPartValue.Value)
	if not AttachTarget then
		return
	end

	local Clone = AttachmentTemplate:Clone()
	Clone.Parent = AttachTarget

	ActiveTalentEffects[petModel] = Clone
end

local function SetupPet(petModel: Model)
	UpdateMoving(petModel)
	ApplyTalentEffect(petModel)

	petModel:GetAttributeChangedSignal("Moving"):Connect(function()
		UpdateMoving(petModel)
	end)

	petModel:GetAttributeChangedSignal("Talent"):Connect(function()
		ApplyTalentEffect(petModel)
	end)

	petModel.Destroying:Connect(function()
		local Effect = ActiveTalentEffects[petModel]
		if Effect then
			Effect:Destroy()
		end
		ActiveTalentEffects[petModel] = nil
	end)
end

for _, petModel in PetsFolder:GetChildren() do
	if petModel:IsA("Model") then
		SetupPet(petModel)
	end
end

PetsFolder.ChildAdded:Connect(function(child)
	if child:IsA("Model") then
		SetupPet(child)
	end
end)
