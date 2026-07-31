local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local WeldSystem = require(ReplicatedStorage.Shared.Utils.WeldSystem)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local WeaponLoader = {}

local WeaponsFolder = ReplicatedStorage.Assets.Weapons

local GRIP_ATTACHMENT_NAME = "GripPoint"

local LoadedWeapons: { [Player]: Model } = {}
local ListenedPlayers: { [Player]: boolean } = {}

local function getHand(character: Model): BasePart?
	return (character:FindFirstChild("RightHand") :: BasePart?) or (character:FindFirstChild("Right Arm") :: BasePart?)
end

local function getGripOffset(): CFrame
	return CFrame.Angles(math.rad(60), math.rad(-200), math.rad(90))
end

local function clearWeapon(player: Player)
	local Existing = LoadedWeapons[player]
	if Existing then
		Existing:Destroy()
	end
	LoadedWeapons[player] = nil
end

local function findWeaponTemplate(weaponName: string): Model?
	for _, descendant in WeaponsFolder:GetDescendants() do
		if descendant:IsA("Model") and descendant.Name == weaponName then
			return descendant
		end
	end

	return nil
end

local function attachWeapon(character: Model, weaponName: string): Model?
	local Hand = getHand(character)
	if not Hand then
		print("no hand")
		return nil
	end

	local Template = findWeaponTemplate(weaponName)
	if not Template then
		warn("[WeaponLoader] Nenhum Model de arma encontrado para: " .. weaponName)
		return nil
	end

	local WeaponModel = Template:Clone()

	local Handle = WeaponModel:FindFirstChild("Handle") :: BasePart?
	if not Handle then
		warn("[WeaponLoader] A arma '" .. weaponName .. "' não tem uma part chamada 'Handle'")
		WeaponModel:Destroy()
		return nil
	end

	WeaponModel.PrimaryPart = Handle
	WeaponModel.Parent = character

	local GripAttachment = Handle:FindFirstChild(GRIP_ATTACHMENT_NAME) :: Attachment?
	local GRIP_OFFSET = getGripOffset()

	if GripAttachment then
		WeaponModel:PivotTo(Hand.CFrame * GripAttachment.CFrame:Inverse() * GRIP_OFFSET)
	else
		WeaponModel:PivotTo(Hand.CFrame * GRIP_OFFSET)
	end

	WeldSystem:Weld(Hand, Handle)

	for _, descendant in WeaponModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Massless = true
		end
	end

	return WeaponModel
end

local function refresh(player: Player, PlayerData: Types.PlayerData)
	local Character = player.Character
	if not Character then
		print("what")
		return
	end

	clearWeapon(player)

	local UUID = PlayerData.Equipment.Weapon()
	if not UUID or UUID == "" then
		print("hk wahat")
		return
	end

	local ItemEntry = PlayerData.Inventory[UUID]()
	if not ItemEntry then
		print("key")
		return
	end

	local WeaponModel = attachWeapon(Character, ItemEntry.Name)
	if WeaponModel then
		print("loaded")
		LoadedWeapons[player] = WeaponModel
	end
end

function WeaponLoader:Listen(player: Player)
	if ListenedPlayers[player] then
		return
	end
	ListenedPlayers[player] = true

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	PlayerData.Equipment.Weapon.Changed(function()
		refresh(player, PlayerData)
	end)

	player.CharacterAdded:Connect(function()
		refresh(player, PlayerData)
	end)

	if player.Character then
		refresh(player, PlayerData)
	end
end

Players.PlayerRemoving:Connect(function(player)
	clearWeapon(player)
	ListenedPlayers[player] = nil
end)

return WeaponLoader
