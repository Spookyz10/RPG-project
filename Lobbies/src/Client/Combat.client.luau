local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Shared.Data).client
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local AttackStyles = require(ReplicatedStorage.Shared.Combat.AttackStyles)
local CombatConstants = require(ReplicatedStorage.Shared.Combat.Constants)
local SoundManager = require(ReplicatedStorage.Shared.SoundManager)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Player = Players.LocalPlayer

local DEFAULT_STYLE = "Solo"

local LastAttackTime = 0
local IsHolding = false

local AttackGui = UIConstants.PlayerGui:WaitForChild("Attack")
local AttackButton = AttackGui:WaitForChild("AttackButton")

local IsMobile = UserInputService.TouchEnabled
	and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled or UserInputService.GamepadEnabled)

AttackButton.Visible = IsMobile

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

local function TryAttack()
	local Style = GetAttackStyle()
	local Cooldown = GetCooldown(Style)
	local Now = os.clock()

	if Now - LastAttackTime < Cooldown then
		return
	end

	LastAttackTime = Now

	local Character = Player.Character
	SoundManager:PlayAttackSound(Character and Character.PrimaryPart)

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

AttackButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		IsHolding = true
		TryAttack()
	end
end)

AttackButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		IsHolding = false
	end
end)

RunService.Heartbeat:Connect(function()
	if IsHolding then
		TryAttack()
	end
end)
