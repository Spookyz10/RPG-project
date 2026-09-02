local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EffectsFolder = ReplicatedStorage.Resources.Effects.Pets
local PetAnimsFolder = ReplicatedStorage.Resources.Animations.PetAnims

local LocalPlayer = Players.LocalPlayer

local PetsFolder = workspace:WaitForChild("Pets")

local FOLLOW_OFFSET_DISTANCE = 3

local ActiveTalentEffects: { [Model]: Instance } = {}
local ActiveConnections: { [Model]: RBXScriptConnection } = {}
local ActiveAnimTracks: { [Model]: { Idle: AnimationTrack?, Walk: AnimationTrack? } } = {}

local function GetAttachTarget(petModel: Model, bodyPartName: string?): Instance?
	if bodyPartName and bodyPartName ~= "" then
		local Target = petModel:FindFirstChild(bodyPartName)
		if Target then
			return Target
		end
	end

	return petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChild("Base")
end

local function ApplyTalentEffect(petModel: Model, talentName: string?)
	local Existing = ActiveTalentEffects[petModel]
	if Existing then
		Existing:Destroy()
		ActiveTalentEffects[petModel] = nil
	end

	if not talentName or talentName == "" then
		return
	end

	local TalentFolder = EffectsFolder:FindFirstChild(talentName)
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

local function SetupHumanoidAnimations(petModel: Model, Humanoid: Humanoid)
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

	ActiveAnimTracks[petModel] = { Idle = IdleTrack, Walk = WalkTrack }

	Humanoid.Running:Connect(function(speed)
		local Tracks = ActiveAnimTracks[petModel]
		if not Tracks then
			return
		end

		if speed > 0.1 then
			if Tracks.Idle then
				Tracks.Idle:Stop()
			end
			if Tracks.Walk then
				Tracks.Walk:Play(0.1)
			end
		else
			if Tracks.Walk then
				Tracks.Walk:Stop()
			end
			if Tracks.Idle then
				Tracks.Idle:Play(0.1)
			end
		end
	end)

	if IdleTrack then
		IdleTrack:Play()
	end
end

local function StartOwnerFollowHumanoid(petModel: Model, Humanoid: Humanoid)
	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		if not petModel.Parent then
			Connection:Disconnect()
			return
		end

		local Character = LocalPlayer.Character
		local OwnerHumanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local OwnerRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
		if not OwnerHumanoid or not OwnerRootPart then
			return
		end

		Humanoid.WalkSpeed = OwnerHumanoid.WalkSpeed
		Humanoid:MoveTo(OwnerRootPart.Position + OwnerRootPart.CFrame.RightVector * FOLLOW_OFFSET_DISTANCE)
	end)

	ActiveConnections[petModel] = Connection
end

local function StartOwnerFollowBase(petModel: Model)
	local Base = petModel:FindFirstChild("Base") :: BasePart?
	local BodyPosition = Base and (Base:FindFirstChild("BodyPosition") :: BodyPosition?)
	local AlignOrientation = Base and (Base:FindFirstChild("AlignOrientation") :: AlignOrientation?)
	if not Base or not BodyPosition then
		return
	end

	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		if not petModel.Parent then
			Connection:Disconnect()
			return
		end

		local Character = LocalPlayer.Character
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

	ActiveConnections[petModel] = Connection
end

local function CleanupPet(petModel: Model)
	local Connection = ActiveConnections[petModel]
	if Connection then
		Connection:Disconnect()
		ActiveConnections[petModel] = nil
	end

	local Effect = ActiveTalentEffects[petModel]
	if Effect then
		Effect:Destroy()
		ActiveTalentEffects[petModel] = nil
	end

	ActiveAnimTracks[petModel] = nil
end

local function SetupPet(petModel: Model)
	local OwnerUserId = petModel:GetAttribute("OwnerUserId")
	local TalentName = petModel:GetAttribute("Talent")

	ApplyTalentEffect(petModel, TalentName)

	local IsOwner = OwnerUserId == LocalPlayer.UserId
	local Humanoid = petModel:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		SetupHumanoidAnimations(petModel, Humanoid)
		if IsOwner then
			StartOwnerFollowHumanoid(petModel, Humanoid)
		end
	elseif IsOwner then
		StartOwnerFollowBase(petModel)
	end

	petModel:GetAttributeChangedSignal("Talent"):Connect(function()
		ApplyTalentEffect(petModel, petModel:GetAttribute("Talent"))
	end)

	petModel.Destroying:Connect(function()
		CleanupPet(petModel)
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
