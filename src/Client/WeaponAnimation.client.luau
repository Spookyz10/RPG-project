local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local Data = require(ReplicatedStorage.Shared.Data).client

local Player = Players.LocalPlayer

local HasWeapon = false

local function IsWeaponEquipped(): boolean
	local UUID = Data.Equipment.Weapon()
	return UUID ~= nil and UUID ~= ""
end

local function UpdateIdle()
	local Character = Player.Character
	if not Character then
		return
	end

	local Handler = AnimationHandler.GetOrCreate(Character)
	if not Handler then
		return
	end

	local ShouldPlay = IsWeaponEquipped()
	if ShouldPlay == HasWeapon then
		return
	end
	HasWeapon = ShouldPlay

	if ShouldPlay then
		Handler:Play("Idle")
	else
		Handler:Stop("Idle")
	end
end

local function OnCharacterAdded(character: Model)
	HasWeapon = false
	character:WaitForChild("Humanoid")
	AnimationHandler.new(character)
	UpdateIdle()
end

Player.CharacterAdded:Connect(OnCharacterAdded)

if Player.Character then
	OnCharacterAdded(Player.Character)
end

Data.Equipment.Weapon.Changed(function()
	UpdateIdle()
end)
