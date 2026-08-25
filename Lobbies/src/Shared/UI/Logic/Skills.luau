local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skills = require(ReplicatedStorage.Shared.Skills)
local ItemDisplay = require(ReplicatedStorage.Shared.UI.ItemDisplay)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local TypeLayoutOrder = {
	Rune = 2,
	Attack = 4,
	Support = 6,
}

local SkillFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

function UI.Init()
	local Data = UIConstants.Data

	local SkillsFrame = UIConstants.Main:WaitForChild("Skills")
	local Container = SkillsFrame.List.Container
	local ItemInfo = SkillsFrame.InfoFrame

	local Template = ReplicatedStorage.Assets.UI.Templates.Skill

	local SelectedSkill: string? = nil

	local SlotButtons = { Q = ItemInfo.Q, E = ItemInfo.E, R = ItemInfo.R }

	local function OpenSkillInfo(skillName: string)
		local SkillInfo = Skills[skillName] :: Types.SkillData
		if not SkillInfo then
			return
		end

		SelectedSkill = skillName

		ItemInfo.Visible = true
		ItemInfo.SkillName.Text = SkillInfo.Name
		ItemInfo.Level.Text = "Level: " .. SkillInfo.LevelRequirement
		ItemInfo.Description.Text = SkillInfo.Description
		ItemInfo.ImageContainer.Icon.Image = SkillInfo.Icon
	end

	local function UpdateSkillFrame(Frame: ImageButton, skillName: string)
		local SkillInfo = Skills[skillName] :: Types.SkillData
		if not SkillInfo then
			return
		end

		Frame.Icon.Image = SkillInfo.Icon
	end

	local function CreateSkillFrame(skillName: string)
		if SkillFrames[skillName] then
			return
		end

		local SkillInfo = Skills[skillName] :: Types.SkillData
		if not SkillInfo then
			return
		end

		if SkillInfo.Type == "Rune" then
			return
		end

		local Frame = Template:Clone()
		Frame.Name = skillName
		Frame.LayoutOrder = TypeLayoutOrder[SkillInfo.SkillType] or 0
		Frame.Parent = Container

		UpdateSkillFrame(Frame, skillName)

		local ClickConnection = Frame.MouseButton1Click:Connect(function()
			OpenSkillInfo(skillName)
		end)

		local HoverConnection = Frame.MouseEnter:Connect(function()
			ItemDisplay:HoverShopItem(Frame, skillName, "Skill")
		end)

		SkillFrames[skillName] = {
			Frame = Frame,
			Disconnectors = {
				function()
					ClickConnection:Disconnect()
				end,
				function()
					HoverConnection:Disconnect()
				end,
			},
		}
	end

	local function RemoveSkillFrame(skillName: string)
		local Entry = SkillFrames[skillName]
		if not Entry then
			return
		end

		for _, Disconnect in Entry.Disconnectors do
			Disconnect()
		end

		Entry.Frame:Destroy()
		SkillFrames[skillName] = nil

		if SelectedSkill == skillName then
			ItemInfo.Visible = false
			SelectedSkill = nil
		end
	end

	ItemInfo.Close.MouseButton1Click:Connect(function()
		ItemInfo.Visible = false
		SelectedSkill = nil
	end)

	for slotName, Button in SlotButtons do
		Button.MouseButton1Click:Connect(function()
			if not SelectedSkill then
				return
			end

			RemoteManager.SendServerEvent("EquipSkill", SelectedSkill, slotName)
		end)
	end

	ItemInfo.Visible = false

	for _, skillName in Data.UnlockedSkills() do
		CreateSkillFrame(skillName)
	end

	Data.UnlockedSkills.OnKeyAdded(function(_, skillName)
		CreateSkillFrame(skillName)
	end)

	Data.UnlockedSkills.OnKeyRemoved(function(_, skillName)
		RemoveSkillFrame(skillName)
	end)
end

return UI
