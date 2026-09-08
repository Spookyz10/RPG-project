local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Skills = require(UI.Parent.Skills)
local RemoteManager = require(UI.Parent.Utils.RemoteManager)
local Bootstrap = require(UI.Bootstrap)
local T = require(UI.Theme)
local Toast = require(UI.Toast)
local Selector = {}
local slotLevels = { Q = 1, E = 20, R = 120 }

function Selector.Init()
	local body = Constants.PlayerGui.SkillSelector.Frame.Body.Content
	local holder = body.Holder
	local template = Bootstrap.GetTemplates().SkillTemplate
	for _, button in body.Sidebar:GetChildren() do
		if button:IsA("GuiButton") then
			button.Activated:Connect(function()
				for _, scroll in holder:GetChildren() do
					if scroll:IsA("ScrollingFrame") then scroll.Visible = scroll.Name == button.Name end
				end
			end)
		end
	end
	for name, skill in Skills do
		local entry = template:Clone()
		entry.Name = name
		entry.LayoutOrder = skill.LevelRequirement
		entry.Visible = true
		entry.Icon.Image = skill.Icon
		entry.SkillName.Text = name
		entry.Desc.Text = skill.Description
		entry.Parent = skill.SkillType == "Support" and holder.Support or holder.Attack
		local function refresh()
			entry.Req.Text = "Level " .. skill.LevelRequirement .. " · Cooldown " .. skill.Cooldown .. "s"
			entry.Req.TextColor3 = Constants.Data.Level() >= skill.LevelRequirement and T.Green or T.Red
			for index, key in { "Q", "E", "R" } do
				local button = entry["Slot" .. index]
				local required = math.max(skill.LevelRequirement, slotLevels[key])
				local equipped = Constants.Data.Skills()[key] == name
				button.Text = Constants.Data.Level() < required and (key .. " · Lv. " .. required) or (equipped and key .. " · Equipped" or "Equip " .. key)
				button.BackgroundColor3 = equipped and T.Mint or T.Soft
			end
		end
		for index, key in { "Q", "E", "R" } do
			entry["Slot" .. index].Activated:Connect(function()
				local required = math.max(skill.LevelRequirement, slotLevels[key])
				if Constants.Data.Level() < required then Toast.Show("Reach level " .. required .. " to use this slot."); return end
				RemoteManager.SendServerEvent("EquipSkill", name, key)
			end)
		end
		Constants.Data.Level.Changed(refresh)
		Constants.Data.Skills.Changed(refresh)
		refresh()
	end
end

return Selector
