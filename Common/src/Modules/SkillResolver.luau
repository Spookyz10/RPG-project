local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedSkills = require(ReplicatedStorage.Shared.Skills)
local SkillBehaviors = require(script.Parent.SkillBehaviors)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SkillResolver = {}

function SkillResolver:GetDefinition(skillName: string): Types.SkillDefinition?
	return SharedSkills[skillName]
end

function SkillResolver:GetBehavior(skillName: string): Types.SkillBehavior?
	return SkillBehaviors[skillName]
end

function SkillResolver:GetEquippedSkill(
	PlayerData: Types.PlayerData,
	slot: string
): (Types.SkillDefinition?, Types.SkillBehavior?)
	local EquippedSkills = PlayerData.Skills()
	local skillName = EquippedSkills[slot]
	if not skillName or skillName == "" then
		return nil, nil
	end

	local Definition = self:GetDefinition(skillName)
	if not Definition then
		return nil, nil
	end

	local Behavior = self:GetBehavior(skillName)
	if not Behavior then
		return nil, nil
	end

	return Definition, Behavior
end

return SkillResolver
