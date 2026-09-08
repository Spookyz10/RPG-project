local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Shared.Data).client
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local AttackStyles = require(ReplicatedStorage.Shared.Combat.AttackStyles)
local CombatConstants = require(ReplicatedStorage.Shared.Combat.Constants)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local DEFAULT_STYLE = "Solo"

local LastAttackTime = 0
local IsHolding = false

local AttackGui = UIConstants.PlayerGui:WaitForChild("Attack")
local AttackButton = AttackGui:WaitForChild("AttackButton")

local IsMobile = UserInputService.TouchEnabled
local HoldingTouch = nil
local Windows = require(ReplicatedStorage.Shared.UI.WindowManager)

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
	if Windows.IsOpen() or UIConstants.PlayerGui:GetAttribute("UIBlocking") or UserInputService:GetFocusedTextBox() then IsHolding = false; return end
	local Style = GetAttackStyle()
	local Cooldown = GetCooldown(Style)
	local Now = os.clock()

	if Now - LastAttackTime < Cooldown then
		return
	end

	LastAttackTime = Now

	RemoteManager.SendServerEvent("Attack")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		IsHolding = true
		TryAttack()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input == HoldingTouch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		IsHolding = false
		HoldingTouch = nil
	end
end)

UserInputService.WindowFocusReleased:Connect(function()
	IsHolding = false
	HoldingTouch = nil
end)

AttackButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		HoldingTouch = input
		IsHolding = true
		TryAttack()
	end
end)

AttackButton.Activated:Connect(TryAttack)
UIConstants.PlayerGui:GetAttributeChangedSignal("UIWindowOpen"):Connect(function()
	IsHolding = false
	HoldingTouch = nil
end)

RunService.Heartbeat:Connect(function()
	if IsHolding then
		TryAttack()
	end
end)
