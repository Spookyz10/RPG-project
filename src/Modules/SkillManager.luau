local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local SkillManager = {}

local LevelSkills = {
	["Ground Break"] = 5,
	["Consecutive Slashes"] = 10,
}

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

function SkillManager:Listen(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	PlayerData.Level.Changed(function(newLevel)
		for skill, level in LevelSkills do
			if level <= newLevel then
				self:GrantSkill(Player, skill)
			end
		end
	end)

	for skill, level in LevelSkills do
		if level <= PlayerData.Level() then
			self:GrantSkill(Player, skill)
		end
	end
end

return SkillManager
