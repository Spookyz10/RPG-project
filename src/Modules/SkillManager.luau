local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SkillManager = {}

function SkillManager:GrantSkill(player: Player, skill: string): boolean
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false
	end

	local UnlockedSkills = PlayerData.UnlockedSkills()
	if table.find(UnlockedSkills, skill) then
		return false
	end

	PlayerData.UnlockedSkills.Insert(skill)
	return true
end

return SkillManager
