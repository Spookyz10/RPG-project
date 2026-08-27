local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local Skills = require(ReplicatedStorage.Shared.Skills)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local VALID_SLOTS = { Q = true, E = true, R = true }

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

	PlayerData.Skills[slot](skill)
end

return SkillManager
