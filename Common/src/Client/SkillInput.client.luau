local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Skills = require(ReplicatedStorage.Shared.Skills)

local SlotKeybinds = {
	[Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.E] = "E",
	[Enum.KeyCode.R] = "R",
}

local SlotButtons = {
	Q = "Slot1",
	E = "Slot2",
	R = "Slot3",
}

local AttackGui = UIConstants.PlayerGui:WaitForChild("Attack")
local Slots = AttackGui:WaitForChild("Slots")

local function UseSkill(slot: string)
	if UIConstants.PlayerGui:GetAttribute("UIWindowOpen") or UIConstants.PlayerGui:GetAttribute("UIBlocking") or UserInputService:GetFocusedTextBox() then return end
	if UIConstants.Data.Skills()[slot] == "" then
		require(ReplicatedStorage.Shared.UI.WindowManager).Open("SkillSelector")
		return
	end
	RemoteManager.SendServerEvent("UseSkill", slot)
end

local function UpdateIcon(slot: string, skillName: string)
	local buttonName = SlotButtons[slot]
	if not buttonName then
		return
	end

	local Button = Slots:FindFirstChild(buttonName)
	if not Button then
		return
	end

	local Icon = Button:FindFirstChild("Icon") :: ImageLabel?
	if not Icon then
		return
	end

	local SkillInfo = skillName ~= "" and Skills[skillName]
	Icon.Image = SkillInfo and SkillInfo.Icon or ""
	Button.SkillName.Text = SkillInfo and skillName or "Choose skill"
end

for slot, buttonName in SlotButtons do
	local Button = Slots:FindFirstChild(buttonName)
	if not Button then
		continue
	end

	Button.Activated:Connect(function()
		UseSkill(slot)
	end)
end

UpdateIcon("Q", UIConstants.Data.Skills.Q())
UpdateIcon("E", UIConstants.Data.Skills.E())
UpdateIcon("R", UIConstants.Data.Skills.R())

UIConstants.Data.Skills.Q.Changed(function(newSkill)
	UpdateIcon("Q", newSkill)
end)

UIConstants.Data.Skills.E.Changed(function(newSkill)
	UpdateIcon("E", newSkill)
end)

UIConstants.Data.Skills.R.Changed(function(newSkill)
	UpdateIcon("R", newSkill)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local slot = SlotKeybinds[input.KeyCode]
	if not slot then
		return
	end

	UseSkill(slot)
end)
