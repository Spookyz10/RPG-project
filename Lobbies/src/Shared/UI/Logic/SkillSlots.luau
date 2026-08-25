local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skills = require(ReplicatedStorage.Shared.Skills)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local function getSlots(chosenSlot: string): { ImageButton }
	local HUD = UIConstants.PlayerGui:FindFirstChild("HUD")
	local slots = {}

	local PCSlots = HUD and HUD:FindFirstChild("PCSlots")
	local MobileSlots = HUD and HUD:FindFirstChild("MobileSlots")

	if PCSlots then
		local slot = PCSlots:FindFirstChild(chosenSlot)
		if slot then
			table.insert(slots, slot)
		end
	end

	if MobileSlots then
		local slot = MobileSlots:FindFirstChild(chosenSlot)
		if slot then
			table.insert(slots, slot)
		end
	end

	return slots
end

local function UpdateSlotIcon(chosenSlot: string, skillName: string)
	local SkillInfo = Skills[skillName] :: Types.SkillData

	for _, slot in getSlots(chosenSlot) do
		local Icon = slot:FindFirstChild("Icon") :: ImageLabel?
		if not Icon then
			continue
		end

		slot.Cooldown.Text = ""

		Icon.Image = (SkillInfo and SkillInfo.Icon) or ""
	end
end

function UI.Init()
	local Data = UIConstants.Data

	for slot, skillName in Data.Skills() do
		UpdateSlotIcon(slot, skillName)
	end

	for slot in Data.Skills() do
		Data.Skills[slot].Changed(function(newSkillName)
			UpdateSlotIcon(slot, newSkillName)
		end)
	end
end

return UI
