local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.Shared.Data).server
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local PetFollowManager = {}

local PetTemplates = ReplicatedStorage.Resources.Pets

local FOLLOW_OFFSET_DISTANCE = 3
local STOP_DISTANCE = 4
local RESUME_DISTANCE = 7
local MAX_TELEPORT_DISTANCE = 60
local FOLLOW_LERP_SPEED = 6

local PetsFolder = workspace:FindFirstChild("Pets") :: Folder?
if not PetsFolder then
	PetsFolder = Instance.new("Folder")
	PetsFolder.Name = "Pets"
	PetsFolder.Parent = workspace
end

local ActivePets: { [Player]: Model } = {}
local ActiveConnections: { [Player]: RBXScriptConnection } = {}
local ListenedPlayers: { [Player]: boolean } = {}

local function GetDisplayPetUUID(PlayerData: Types.PlayerData): string?
	local VanityUUID = PlayerData.VanityPet()
	if VanityUUID and VanityUUID ~= "" then
		return VanityUUID
	end

	local EquippedUUID = PlayerData.EquippedPet()
	if EquippedUUID and EquippedUUID ~= "" then
		return EquippedUUID
	end

	return nil
end

local function DespawnPet(player: Player)
	local Connection = ActiveConnections[player]
	if Connection then
		Connection:Disconnect()
		ActiveConnections[player] = nil
	end

	local ExistingPet = ActivePets[player]
	if ExistingPet then
		ExistingPet:Destroy()
		ActivePets[player] = nil
	end
end

local function PreparePetModel(petModel: Model)
	local Humanoid = petModel:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		Humanoid.PlatformStand = false
	end

	for _, descendant in petModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.Massless = true
		end
	end
end

local function StartFollowing(player: Player, petModel: Model)
	local Connection = RunService.Heartbeat:Connect(function(dt)
		local Character = player.Character
		local RootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)

		if not RootPart or not petModel.Parent then
			return
		end

		local TargetPosition = RootPart.Position + RootPart.CFrame.RightVector * FOLLOW_OFFSET_DISTANCE
		local CurrentCFrame = petModel:GetPivot()
		local Distance = (TargetPosition - CurrentCFrame.Position).Magnitude

		if Distance > MAX_TELEPORT_DISTANCE then
			petModel:PivotTo(CFrame.lookAt(TargetPosition, TargetPosition + RootPart.CFrame.LookVector))
			petModel:SetAttribute("Moving", false)
			return
		end

		local WasMoving = petModel:GetAttribute("Moving") == true
		local IsMoving = WasMoving

		if WasMoving and Distance <= STOP_DISTANCE then
			IsMoving = false
		elseif not WasMoving and Distance > RESUME_DISTANCE then
			IsMoving = true
		end

		if IsMoving ~= WasMoving then
			petModel:SetAttribute("Moving", IsMoving)
		end

		if not IsMoving then
			return
		end

		local GoalCFrame = CFrame.lookAt(TargetPosition, TargetPosition + RootPart.CFrame.LookVector)
		local Alpha = math.clamp(FOLLOW_LERP_SPEED * dt, 0, 1)
		petModel:PivotTo(CurrentCFrame:Lerp(GoalCFrame, Alpha))
	end)

	ActiveConnections[player] = Connection
end

local function SpawnPet(player: Player, PetEntry: Types.PetData)
	DespawnPet(player)

	local Template = PetTemplates:FindFirstChild(PetEntry.Name)
	if not Template then
		return
	end

	local Character = player.Character
	local RootPart = Character and (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
	if not RootPart then
		return
	end

	local PetModel = Template:Clone() :: Model
	PetModel.Name = player.Name .. "_Pet"
	PetModel:SetAttribute("PetName", PetEntry.Name)
	PetModel:SetAttribute("Talent", PetEntry.Talent or "")
	PetModel:SetAttribute("Moving", false)

	PreparePetModel(PetModel)

	PetModel:PivotTo(RootPart.CFrame * CFrame.new(FOLLOW_OFFSET_DISTANCE, 0, 0))
	PetModel.Parent = PetsFolder

	ActivePets[player] = PetModel
	StartFollowing(player, PetModel)
end

function PetFollowManager:Refresh(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		DespawnPet(player)
		return
	end

	local DisplayUUID = GetDisplayPetUUID(PlayerData)
	if not DisplayUUID then
		DespawnPet(player)
		return
	end

	local PetEntry = PlayerData.Pets[DisplayUUID]()
	if not PetEntry then
		DespawnPet(player)
		return
	end

	local Existing = ActivePets[player]
	if
		Existing
		and Existing:GetAttribute("PetName") == PetEntry.Name
		and Existing:GetAttribute("Talent") == (PetEntry.Talent or "")
	then
		return
	end

	SpawnPet(player, PetEntry)
end

function PetFollowManager:Listen(player: Player)
	if ListenedPlayers[player] then
		return
	end
	ListenedPlayers[player] = true

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	PlayerData.EquippedPet.Changed(function()
		self:Refresh(player)
	end)

	PlayerData.VanityPet.Changed(function()
		self:Refresh(player)
	end)

	PlayerData.Pets.Changed(function()
		self:Refresh(player)
	end)

	player.CharacterAdded:Connect(function()
		self:Refresh(player)
	end)

	self:Refresh(player)
end

function PetFollowManager.OnPlayerRemoved(player: Player)
	DespawnPet(player)
	ListenedPlayers[player] = nil
end

return PetFollowManager
