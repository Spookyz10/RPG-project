local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Skills = require(ReplicatedStorage.Shared.Skills)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SkillSelector = {}

local SlotToKey = { Slot1 = "Q", Slot2 = "E", Slot3 = "R" }
local DEFAULT_TAB = "Attack"

local Holder: Instance = nil
local Template: GuiObject = nil
local Overlay: Frame = nil

local function CreateEntry(skillName: string, SkillInfo: Types.SkillDefinition)
	local TargetScroll = (SkillInfo.SkillType == "Support") and Holder.Support or Holder.Attack

	local Entry = Template:Clone()
	Entry.Name = skillName
	Entry.Icon.Image = SkillInfo.Icon
	Entry.Visible = true

	for slotName, dataKey in SlotToKey do
		local Button = Entry:FindFirstChild(slotName)
		if not Button then
			continue
		end

		Button.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("EquipSkill", skillName, dataKey)
		end)
	end

	Entry.MouseEnter:Connect(function()
		Overlay.SkillName.Text = skillName
		Overlay.Req.Text = " Lv:" .. tostring(SkillInfo.LevelRequirement)
		Overlay.Desc.Text = SkillInfo.Description
		Overlay.Position = UDim2.fromOffset(Entry.AbsolutePosition.X + 20, Entry.AbsolutePosition.Y + 1)
		Overlay.Visible = true
	end)

	Entry.MouseLeave:Connect(function()
		Overlay.Visible = false
	end)

	Entry.Parent = TargetScroll
end

local function SetupSidebar(Sidebar: Instance)
	for _, Button in Sidebar:GetChildren() do
		if not Button:IsA("TextButton") then
			continue
		end

		Button.MouseButton1Click:Connect(function()
			for _, Frame in Holder:GetChildren() do
				if Frame:IsA("ScrollingFrame") then
					Frame.Visible = Frame.Name == Button.Name
				end
			end
		end)
	end
end

function SkillSelector.Init()
	local SkillSelectorGui = UIConstants.PlayerGui:WaitForChild("SkillSelector")
	local Frame = SkillSelectorGui:WaitForChild("Frame")

	Holder = Frame:WaitForChild("Holder")
	Template = ReplicatedStorage.Resources.UI.Templates:WaitForChild("SkillTemplate")
	Template.Visible = false

	Overlay = SkillSelectorGui:WaitForChild("Overlay") :: Frame
	Overlay.Visible = false

	for _, ScrollFrame in Holder:GetChildren() do
		if ScrollFrame:IsA("ScrollingFrame") then
			ScrollFrame.Visible = ScrollFrame.Name == DEFAULT_TAB
		end
	end

	SetupSidebar(Frame:WaitForChild("Sidebar"))

	for skillName, SkillInfo in Skills do
		CreateEntry(skillName, SkillInfo)
	end
end

return SkillSelector
