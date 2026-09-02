local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EffectsFolder = ReplicatedStorage.Resources.Effects.Pets
local PetAnimsFolder = ReplicatedStorage.Resources.Animations.PetAnims
local PetsFolder = workspace:WaitForChild("Pets")

local FOLLOW_OFFSET_DISTANCE = 3
local MAX_TELEPORT_DISTANCE = 60

local ActiveTalentEffects: { [Model]: Instance } = {}
local ActiveFollowConnections: { [Model]: RBXScriptConnection } = {}

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

local function SetupHumanoidPet(petModel: Model, Humanoid: Humanoid)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)

	local IdleAnim = PetAnimsFolder:FindFirstChild("PetIdle") :: Animation?
	local WalkAnim = PetAnimsFolder:FindFirstChild("PetWalk") :: Animation?

	local IdleTrack = IdleAnim and Humanoid:LoadAnimation(IdleAnim)
	local WalkTrack = WalkAnim and Humanoid:LoadAnimation(WalkAnim)

	if IdleTrack then
		IdleTrack.Looped = true
	end
	if WalkTrack then
		WalkTrack.Looped = true
	end

	Humanoid.Running:Connect(function(speed)
		if speed > 0.1 then
			if IdleTrack then
				IdleTrack:Stop(0.1)
			end
			if WalkTrack then
				WalkTrack:Play(0.1)
			end
		else
			if WalkTrack then
				WalkTrack:Stop(0.1)
			end
			if IdleTrack then
				IdleTrack:Play(0.1)
			end
		end
	end)

	if IdleTrack then
		IdleTrack:Play(0.1)
	end
end

local function StartFollowingHumanoid(petModel: Model, Humanoid: Humanoid)
	local OwnerUserId = petModel:GetAttribute("OwnerUserId")
	local OwnerPlayer = typeof(OwnerUserId) == "number" and Players:GetPlayerByUserId(OwnerUserId)

	if not OwnerPlayer then
		return
	end

	local RootPart = petModel:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not RootPart then
		return
	end

	local Connection = RunService.Heartbeat:Connect(function()
		if not petModel.Parent or not OwnerPlayer.Parent then
			return
		end

		local Character = OwnerPlayer.Character
		local OwnerRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
		local OwnerHumanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if not OwnerRootPart or not OwnerHumanoid then
			return
		end

		local TargetPosition = OwnerRootPart.Position + OwnerRootPart.CFrame.RightVector * FOLLOW_OFFSET_DISTANCE
		local Distance = (TargetPosition - RootPart.Position).Magnitude

		if Distance > MAX_TELEPORT_DISTANCE then
			petModel:PivotTo(CFrame.lookAt(TargetPosition, TargetPosition + OwnerRootPart.CFrame.LookVector))
			return
		end

		Humanoid.WalkSpeed = OwnerHumanoid.WalkSpeed

		if Distance > 4 then
			Humanoid:MoveTo(TargetPosition)
		else
			Humanoid:Move(Vector3.zero)
		end
	end)

	ActiveFollowConnections[petModel] = Connection
end

local function StartFollowingBase(petModel: Model)
	local OwnerUserId = petModel:GetAttribute("OwnerUserId")
	local OwnerPlayer = typeof(OwnerUserId) == "number" and Players:GetPlayerByUserId(OwnerUserId)

	if not OwnerPlayer then
		return
	end

	local Base = petModel:FindFirstChild("Base") :: BasePart?
	local BodyPosition = Base and (Base:FindFirstChild("BodyPosition") :: BodyPosition?)
	local AlignOrientation = Base and (Base:FindFirstChild("AlignOrientation") :: AlignOrientation?)
	if not Base or not BodyPosition then
		return
	end

	local Connection = RunService.Heartbeat:Connect(function()
		if not petModel.Parent or not OwnerPlayer.Parent then
			return
		end

		local Character = OwnerPlayer.Character
		local OwnerRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
		if not OwnerRootPart then
			return
		end

		BodyPosition.Position = OwnerRootPart.Position
			+ Vector3.new(0, 2.6, 0)
			+ -OwnerRootPart.CFrame.RightVector * -3.2

		if AlignOrientation then
			AlignOrientation.Attachment1 = OwnerRootPart:FindFirstChild("RootAttachment") :: Attachment?
		end
	end)

	ActiveFollowConnections[petModel] = Connection
end

local function SetupPet(petModel: Model)
	ApplyTalentEffect(petModel)

	local Humanoid = petModel:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		SetupHumanoidPet(petModel, Humanoid)
		StartFollowingHumanoid(petModel, Humanoid)
	else
		StartFollowingBase(petModel)
	end

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
