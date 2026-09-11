local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local WeldSystem = require(ReplicatedStorage.Shared.Utils.WeldSystem)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local WeaponLoader = {}

local WeaponsFolder = ReplicatedStorage.Resources.Weapons

local GRIP_ATTACHMENT_NAME = "GripPoint"

local LoadedWeapons: { [Player]: Model } = {}
local ListenedPlayers: { [Player]: boolean } = {}

local function getHand(character: Model): BasePart?
	return character:FindFirstChild("Right Arm") :: BasePart?
end

-- Orientation uses degrees and the same rotation order as Attachment.Orientation.
local DefaultGripAttributes = {
	GripPosition = Vector3.new(0, -1, 0),
	GripOrientation = Vector3.zero,
}
for attribute, defaultValue in DefaultGripAttributes do
	if script:GetAttribute(attribute) == nil then
		script:SetAttribute(attribute, defaultValue)
	end
end

local function getGripOffset(weapon: Model): CFrame
	local function getVector(attribute: string): Vector3
		local Value = weapon:GetAttribute(attribute)
		if typeof(Value) ~= "Vector3" then
			Value = script:GetAttribute(attribute)
		end
		return if typeof(Value) == "Vector3" then Value else Vector3.zero
	end

	local Position = getVector("GripPosition")
	local Orientation = getVector("GripOrientation")
	return CFrame.new(Position)
		* CFrame.fromOrientation(math.rad(Orientation.X), math.rad(Orientation.Y), math.rad(Orientation.Z))
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
		return nil
	end

	local Template = findWeaponTemplate(weaponName)
	if not Template then
		return nil
	end

	local WeaponModel = Template:Clone()
	WeaponModel.Name = "Sword"

	local Handle = WeaponModel:FindFirstChild("Handle") :: BasePart?
	if not Handle then
		WeaponModel:Destroy()
		return nil
	end

	WeaponModel.PrimaryPart = Handle
	WeaponModel.Parent = character

	local GripPoint = Handle:FindFirstChild(GRIP_ATTACHMENT_NAME)
	local GripAttachment = if GripPoint and GripPoint:IsA("Attachment") then GripPoint else nil
	local GripWeld = Instance.new("Weld")
	GripWeld.Name = "WeaponGrip"
	GripWeld.C0 = getGripOffset(WeaponModel)
	GripWeld.C1 = if GripAttachment then GripAttachment.CFrame else CFrame.identity
	WeaponModel:PivotTo(Hand.CFrame * GripWeld.C0 * GripWeld.C1:Inverse())
	GripWeld.Part0 = Hand
	GripWeld.Part1 = Handle
	GripWeld.Parent = Handle

	local Connections: { RBXScriptConnection } = {}
	local function updateGrip()
		GripWeld.C0 = getGripOffset(WeaponModel)
		GripWeld.C1 = if GripAttachment then GripAttachment.CFrame else CFrame.identity
	end

	for _, attribute in { "GripPosition", "GripOrientation" } do
		table.insert(Connections, script:GetAttributeChangedSignal(attribute):Connect(updateGrip))
		table.insert(Connections, WeaponModel:GetAttributeChangedSignal(attribute):Connect(updateGrip))
	end
	if GripAttachment then
		table.insert(Connections, GripAttachment:GetPropertyChangedSignal("CFrame"):Connect(updateGrip))
	end
	WeaponModel.Destroying:Connect(function()
		for _, connection in Connections do
			connection:Disconnect()
		end
	end)

	for _, descendant in WeaponModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Massless = true

			if descendant ~= Handle then
				WeldSystem:Weld(Handle, descendant)
			end
		end
	end

	return WeaponModel
end

local function refresh(player: Player, PlayerData: Types.PlayerData)
	local Character = player.Character
	if not Character then
		return
	end

	clearWeapon(player)

	local WeaponUUID = PlayerData.Equipment.Weapon()
	if not WeaponUUID or WeaponUUID == "" then
		return
	end

	local VanityUUID = PlayerData.Vanity.Weapon()
	local DisplayUUID = (VanityUUID and VanityUUID ~= "") and VanityUUID or WeaponUUID

	local ItemEntry = PlayerData.Inventory[DisplayUUID]()
	if not ItemEntry then
		ItemEntry = PlayerData.Inventory[WeaponUUID]()
		if not ItemEntry then
			return
		end
	end

	local WeaponModel = attachWeapon(Character, ItemEntry.Name)
	if WeaponModel then
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

	PlayerData.Vanity.Weapon.Changed(function()
		refresh(player, PlayerData)
	end)

	player.CharacterAdded:Connect(function()
		refresh(player, PlayerData)
	end)

	if player.Character then
		refresh(player, PlayerData)
	end
end

function WeaponLoader.OnPlayerRemoved(Player: Player)
	clearWeapon(Player)
	ListenedPlayers[Player] = nil
end

return WeaponLoader
