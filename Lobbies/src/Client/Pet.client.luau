local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)

local EffectsFolder = ReplicatedStorage.Resources.Effects.Pets
local PetsFolder = workspace:WaitForChild("Pets")

local MOVING_ANIMATIONS = { "PetIdle", "PetWalk" }

local FOLLOW_OFFSET_DISTANCE = 3
local STOP_DISTANCE = 4
local RESUME_DISTANCE = 7
local MAX_TELEPORT_DISTANCE = 60
local FOLLOW_LERP_SPEED = 8

local ActiveTalentEffects: { [Model]: Instance } = {}
local ActiveFollowConnections: { [Model]: RBXScriptConnection } = {}

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

local function UpdateMoving(petModel: Model, isMoving: boolean)
	SetAnimation(petModel, isMoving and "PetWalk" or "PetIdle")
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

local function StartFollowing(petModel: Model)
	local OwnerUserId = petModel:GetAttribute("OwnerUserId")
	local OwnerPlayer = typeof(OwnerUserId) == "number" and Players:GetPlayerByUserId(OwnerUserId)

	if not OwnerPlayer then
		return
	end

	local IsMoving = false

	local Connection = RunService.Heartbeat:Connect(function(dt)
		if not petModel.Parent or not OwnerPlayer.Parent then
			return
		end

		local Character = OwnerPlayer.Character
		local OwnerRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
		if not OwnerRootPart then
			return
		end

		local CurrentCFrame = petModel:GetPivot()
		local TargetPosition = OwnerRootPart.Position + OwnerRootPart.CFrame.RightVector * FOLLOW_OFFSET_DISTANCE
		local Distance = (TargetPosition - CurrentCFrame.Position).Magnitude

		if Distance > MAX_TELEPORT_DISTANCE then
			petModel:PivotTo(CFrame.lookAt(TargetPosition, TargetPosition + OwnerRootPart.CFrame.LookVector))
			if IsMoving then
				IsMoving = false
				UpdateMoving(petModel, false)
			end
			return
		end

		if IsMoving and Distance <= STOP_DISTANCE then
			IsMoving = false
			UpdateMoving(petModel, false)
		elseif not IsMoving and Distance > RESUME_DISTANCE then
			IsMoving = true
			UpdateMoving(petModel, true)
		end

		if not IsMoving then
			return
		end

		local GoalCFrame = CFrame.lookAt(TargetPosition, TargetPosition + OwnerRootPart.CFrame.LookVector)
		local Alpha = math.clamp(FOLLOW_LERP_SPEED * dt, 0, 1)
		petModel:PivotTo(CurrentCFrame:Lerp(GoalCFrame, Alpha))
	end)

	ActiveFollowConnections[petModel] = Connection
end

local function SetupPet(petModel: Model)
	UpdateMoving(petModel, false)
	ApplyTalentEffect(petModel)
	StartFollowing(petModel)

	petModel:GetAttributeChangedSignal("Talent"):Connect(function()
		ApplyTalentEffect(petModel)
	end)

	petModel.Destroying:Connect(function()
		local Effect = ActiveTalentEffects[petModel]
		if Effect then
			Effect:Destroy()
		end
		ActiveTalentEffects[petModel] = nil

		local Connection = ActiveFollowConnections[petModel]
		if Connection then
			Connection:Disconnect()
			ActiveFollowConnections[petModel] = nil
		end
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
