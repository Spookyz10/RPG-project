local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Functions = {}

local Data = require(ReplicatedStorage.Shared.Data).server
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local MobsData = require(ReplicatedStorage.Shared.MobsData)
local Types = require(script.Parent.Types)

function Functions:getDistance(part1: BasePart, part2: BasePart): number
	return (part1.Position - part2.Position).Magnitude
end

function Functions:isEntityAlive(class: Types.Entity): boolean
	return class.HP > 0
end

function Functions:isClassMob(class: Types.Entity): boolean
	return not Players:GetPlayerFromCharacter(class.Model)
end

function Functions:GenUUID(): string
	return HttpService:GenerateGUID(false)
end

function Functions:HasKeyWithValueIntable(table: {}, field: string, value: any): (boolean, any)
	for key, val in table do
		if val[field] == value then
			return true, key
		end
	end
	return false, nil
end

local function getTotalStats(Equipment, Stat)
	Stat = 0
	for _, Item in Equipment do
		local ItemInfo = ItemsData[Item]
		if ItemInfo then
			Stat += ItemInfo[Stat]
		end
	end

	return Stat
end

function Functions:GetStatsFromClass(class: Types.Entity): Types.Stats
	local isMob = self:isClassMob(class)
	if isMob then
		return MobsData[class.Model.Name] and MobsData[class.Model.Name].Stats
	else
		local PlayerData = Data.Service:waitForData(Players:GetPlayerFromCharacter(class.Model))
		local Equipment = PlayerData.Equipment()

		return {
			Attack = getTotalStats(Equipment, "Attack"),
			Defense = getTotalStats(Equipment, "Defense"),
			CriticalChance = getTotalStats(Equipment, "CriticalChance"),
			CriticalPower = getTotalStats(Equipment, "CriticalPower"),
			Luck = getTotalStats(Equipment, "Luck"),
		}
	end
end

return Functions
