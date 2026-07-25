local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Functions = {}

local Data = require(ReplicatedStorage.Shared.Data).server
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)

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
	local MobsData = require(ReplicatedStorage.Shared.MobsData)

	if isMob then
		return MobsData[class.Model.Name] and MobsData[class.Model.Name].Stats
	else
		local PlayerData = Data.Service:waitForData(Players:GetPlayerFromCharacter(class.Model)) :: Types.PlayerData
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

function Functions:GetXPNeeded(level: number): number
	return 25 * math.floor((100 + (25 / 6) * level * (level + 1) - (25 / 3) * math.max(0, 2 - level)) / 25 + 0.5)
end

function Functions:GetNearestPlayer(part: BasePart, range: number): Player?
	local nearestPlayer = nil
	local nearestDistance = range

	for _, player in Players:GetPlayers() do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = self:getDistance(part, player.Character.HumanoidRootPart)
			if distance < nearestDistance then
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end

	return nearestPlayer
end

function Functions:GetTargetPlayer(mobModel: Model, hitlist: { [Player]: number }?): Player?
	if hitlist then
		local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
		local HighestDamage = 0
		local HighestPlayer = nil
		for player, damage in hitlist do
			local playerClass = PlayerClass.getPlayerInfo(player)
			if not Functions:isEntityAlive(playerClass) then
				continue
			end

			if damage > HighestDamage then
				HighestDamage = damage
				HighestPlayer = player
			end
		end

		return HighestPlayer
	else
		return self:GetNearestPlayer(mobModel.PrimaryPart, 30)
	end
end

return Functions
