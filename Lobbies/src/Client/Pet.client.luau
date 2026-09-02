local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PetTemplates = ReplicatedStorage.Resources.Pets
local EffectsFolder = ReplicatedStorage.Resources.Effects.Pets
local PetAnimsFolder = ReplicatedStorage.Resources.Animations.PetAnims

local FOLLOW_OFFSET_DISTANCE = 3
local MAX_DISTANCE = 100

local ActivePets: { [Player]: Model } = {}
local ActiveConnections: { [Player]: RBXScriptConnection } = {}
local ActiveTalentEffects: { [Model]: Instance } = {}

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

local function DespawnPet(owner: Player)
	local Connection = ActiveConnections[owner]
	if Connection then
		Connection:Disconnect()
		ActiveConnections[owner] = nil
	end

	local PetModel = ActivePets[owner]
	if PetModel then
		local Effect = ActiveTalentEffects[PetModel]
		if Effect then
			Effect:Destroy()
			ActiveTalentEffects[PetModel] = nil
		end

		PetModel:Destroy()
		ActivePets[owner] = nil
	end
end

local function StartFollowingHumanoid(petModel: Model, Humanoid: Humanoid, owner: Player)
	local RootPart = petModel.PrimaryPart or (petModel:FindFirstChild("HumanoidRootPart") :: BasePart?)

	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		if not petModel.Parent or not owner.Parent then
			return
		end

		local Character = owner.Character
		local OwnerHumanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local OwnerRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
		if not OwnerHumanoid or not OwnerRootPart then
			return
		end

		if RootPart then
			local Distance = (OwnerRootPart.Position - RootPart.Position).Magnitude
			if Distance >= MAX_DISTANCE then
				DespawnPet(owner)
				return
			end
		end

		Humanoid.WalkSpeed = OwnerHumanoid.WalkSpeed
		Humanoid:MoveTo(OwnerRootPart.Position + OwnerRootPart.CFrame.RightVector * FOLLOW_OFFSET_DISTANCE)
	end)

	ActiveConnections[owner] = Connection
end

local function StartFollowingBase(petModel: Model, owner: Player)
	local Base = petModel:FindFirstChild("Base") :: BasePart?
	local BodyPosition = Base and (Base:FindFirstChild("BodyPosition") :: BodyPosition?)
	local AlignOrientation = Base and (Base:FindFirstChild("AlignOrientation") :: AlignOrientation?)
	if not Base or not BodyPosition then
		return
	end

	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		if not petModel.Parent or not owner.Parent then
			return
		end

		local Character = owner.Character
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

	ActiveConnections[owner] = Connection
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
				IdleTrack:Stop()
			end
			if WalkTrack then
				WalkTrack:Play(0.1)
			end
		else
			if WalkTrack then
				WalkTrack:Stop()
			end
			if IdleTrack then
				IdleTrack:Play(0.1)
			end
		end
	end)

	if IdleTrack then
		IdleTrack:Play()
	end
end

local function SpawnPet(owner: Player, petName: string, talentName: string?)
	DespawnPet(owner)

	local Template = PetTemplates:FindFirstChild(petName)
	if not Template then
		return
	end

	local Character = owner.Character
	local OwnerRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
	if not OwnerRootPart then
		return
	end

	local PetModel = Template:Clone() :: Model
	PetModel.Name = owner.Name .. "_Pet"
	PetModel:SetAttribute("PetName", petName)
	PetModel:SetAttribute("Talent", talentName or "")

	local Humanoid = PetModel:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		PetModel:PivotTo(OwnerRootPart.CFrame)
	else
		local Base = PetModel:FindFirstChild("Base") :: BasePart?
		if Base then
			Base.Position = OwnerRootPart.Position + Vector3.new(0, 3, 0) + -OwnerRootPart.CFrame.RightVector * -3
			local AlignOrientation = Base:FindFirstChild("AlignOrientation") :: AlignOrientation?
			if AlignOrientation then
				AlignOrientation.Attachment1 = OwnerRootPart:FindFirstChild("RootAttachment") :: Attachment?
			end
		end
	end

	PetModel.Parent = workspace

	ApplyTalentEffect(PetModel, talentName)

	ActivePets[owner] = PetModel

	if Humanoid then
		SetupHumanoidPet(PetModel, Humanoid)
		StartFollowingHumanoid(PetModel, Humanoid, owner)
	else
		StartFollowingBase(PetModel, owner)
	end
end

local function OnPetNameChanged(owner: Player)
	local PetName = owner:GetAttribute("DisplayPetName")

	if typeof(PetName) ~= "string" or PetName == "" then
		DespawnPet(owner)
		return
	end

	local Existing = ActivePets[owner]
	if Existing and Existing:GetAttribute("PetName") == PetName then
		return
	end

	local Talent = owner:GetAttribute("DisplayPetTalent")
	SpawnPet(owner, PetName, Talent)
end

local function OnPetTalentChanged(owner: Player)
	local PetModel = ActivePets[owner]
	if not PetModel then
		return
	end

	local Talent = owner:GetAttribute("DisplayPetTalent")
	PetModel:SetAttribute("Talent", Talent or "")
	ApplyTalentEffect(PetModel, Talent)
end

local function SetupPlayer(owner: Player)
	owner:GetAttributeChangedSignal("DisplayPetName"):Connect(function()
		OnPetNameChanged(owner)
	end)

	owner:GetAttributeChangedSignal("DisplayPetTalent"):Connect(function()
		OnPetTalentChanged(owner)
	end)

	owner.CharacterAdded:Connect(function()
		OnPetNameChanged(owner)
	end)

	OnPetNameChanged(owner)
end

for _, player in Players:GetPlayers() do
	SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(player)
	DespawnPet(player)
end)
