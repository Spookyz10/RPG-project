local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Functions = {}

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

local function getTotalStats(Data: Types.PlayerData, StatName: string)
	local Stat = 0
	for _, Item in Data.Equipment do
		local KeyEntry = Data.Inventory[Item]
		if not KeyEntry then
			continue
		end

		local ItemInfo = ItemsData[KeyEntry.Name] :: Types.Equipment
		if ItemInfo then
			Stat += ItemInfo.Stats[StatName]
		end
	end

	if Data.ExtraStats[StatName] then
		Stat += Data.ExtraStats[StatName]
	end

	return Stat
end

function Functions:GetTotalStats(entity: Model, Data: Types.PlayerData): Types.Stats
	local isMob = entity:FindFirstChild("UUID")

	if isMob then
		local MobsData = require(ReplicatedStorage.Shared.MobsData)
		return MobsData[entity.Name] and MobsData[entity.Name].Stats
	else
		return {
			Attack = getTotalStats(Data, "Attack"),
			Defense = getTotalStats(Data, "Defense"),
			CriticalChance = getTotalStats(Data, "CriticalChance"),
			CriticalPower = getTotalStats(Data, "CriticalPower"),
			Luck = getTotalStats(Data, "Luck"),
			Health = getTotalStats(Data, "Health"),
			Speed = getTotalStats(Data, "Speed"),
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

function Functions:getMob(name: string)
	for _, mob: Model in ReplicatedStorage:FindFirstChild("Mobs"):GetDescendants() do
		if mob:IsA("Model") and mob.Name == name then
			return mob
		end
	end

	return nil
end

return Functions
