local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local PetFollowManager = {}

local PetTemplates = ReplicatedStorage.Resources.Pets

local PetsFolder = workspace:FindFirstChild("Pets") :: Folder

local ActivePets: { [Player]: Model } = {}
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
	local ExistingPet = ActivePets[player]
	if ExistingPet then
		ExistingPet:Destroy()
		ActivePets[player] = nil
	end
end

local function GetRootPart(petModel: Model): BasePart?
	return petModel.PrimaryPart
		or (petModel:FindFirstChild("HumanoidRootPart") :: BasePart?)
		or petModel:FindFirstChild("Base") :: BasePart?
end

local function PreparePetModel(petModel: Model)
	local RootPart = GetRootPart(petModel)

	for _, descendant in petModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.Massless = descendant ~= RootPart
		elseif descendant:IsA("Humanoid") then
			descendant.WalkSpeed = 16
			descendant.JumpPower = 0
			descendant.JumpHeight = 0
			descendant:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			descendant:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			descendant:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			descendant:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			descendant:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
			descendant:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
		end
	end

	if RootPart then
		RootPart.Massless = false
	end
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
	PetModel:SetAttribute("OwnerUserId", player.UserId)

	PreparePetModel(PetModel)

	PetModel:PivotTo(RootPart.CFrame * CFrame.new(3, 30, 0))
	PetModel.Parent = PetsFolder

	local PetRoot = GetRootPart(PetModel)
	if PetRoot then
		pcall(function()
			PetRoot:SetNetworkOwner(player)
		end)
	end

	ActivePets[player] = PetModel
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
