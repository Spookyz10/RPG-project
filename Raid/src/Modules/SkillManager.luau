local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local Skills = require(ReplicatedStorage.Shared.Skills)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local VALID_SLOTS = { Q = true, E = true, R = true }

local SLOT_LEVEL_REQUIREMENT = {
	Q = 1,
	E = 20,
	R = 120,
}

local SkillManager = {}

function SkillManager:EquipSkill(player: Player, skill: string, slot: string)
	if typeof(skill) ~= "string" or typeof(slot) ~= "string" then
		return
	end

	if not VALID_SLOTS[slot] then
		return
	end

	local SkillInfo = Skills[skill] :: Types.SkillDefinition
	if not SkillInfo then
		return
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if not SkillInfo:Elligable(PlayerData()) then
		return
	end

	local RequiredLevel = SLOT_LEVEL_REQUIREMENT[slot]
	if RequiredLevel and PlayerData.Level() < RequiredLevel then
		return
	end

	local EquippedSkills = PlayerData.Skills()
	for equippedSlot, equippedSkill in EquippedSkills do
		if equippedSkill == skill and equippedSlot ~= slot then
			PlayerData.Skills[equippedSlot]("")
		end
	end

	PlayerData.Skills[slot](skill)
end

return SkillManager
