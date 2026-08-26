local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Shared.Data).client
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local AttackStyles = require(ReplicatedStorage.Shared.Combat.AttackStyles)
local CombatConstants = require(ReplicatedStorage.Shared.Combat.Constants)
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Player = Players.LocalPlayer

local DEFAULT_STYLE = "Solo"

local ComboIndex = 0
local LastAttackTime = 0
local IsHolding = false

local function GetAttackStyle()
	local UUID = Data.Equipment.Weapon()
	if not UUID or UUID == "" then
		return AttackStyles[DEFAULT_STYLE]
	end

	local ItemEntry = Data.Inventory[UUID]()
	if not ItemEntry then
		return AttackStyles[DEFAULT_STYLE]
	end

	local ItemInfo = ItemsData[ItemEntry.Name] :: Types.Equipment
	local WeaponType = ItemInfo and ItemInfo.WeaponType

	return (WeaponType and AttackStyles[WeaponType]) or AttackStyles[DEFAULT_STYLE]
end

local function GetCooldown(Style)
	return Style.Cooldown or CombatConstants.SwingCooldown
end

local function PlayAttackAnimation(Style)
	local Character = Player.Character
	if not Character then
		return
	end

	local Handler = AnimationHandler.GetOrCreate(Character)
	Handler:Play(Style.Prefix .. ComboIndex, 0.1)
end

local function TryAttack()
	local Style = GetAttackStyle()
	local Cooldown = GetCooldown(Style)
	local Now = os.clock()

	if Now - LastAttackTime < Cooldown then
		return
	end

	if Now - LastAttackTime > Cooldown * CombatConstants.ComboResetMultiplier then
		ComboIndex = 0
	end

	LastAttackTime = Now
	ComboIndex = (ComboIndex % Style.MaxCombo) + 1

	PlayAttackAnimation(Style)
	RemoteManager.SendServerEvent("Attack")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		IsHolding = true
		TryAttack()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		IsHolding = false
	end
end)

RunService.Heartbeat:Connect(function()
	if IsHolding then
		TryAttack()
	end
end)
