local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Functions = {}

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local ItemsDataByName = require(ReplicatedStorage.Shared.ItemsDataByName)

local Types = require(script.Parent.Types)

local ENTITY_COLLISION_GROUP = "Entities"

local NON_UPGRADABLE_STATS = {
	Luck = true,
	Speed = true,
}

function Functions:getDistance(part1: BasePart, part2: BasePart): number
	return (part1.Position - part2.Position).Magnitude
end

function Functions:isEntityAlive(character: Model): boolean
	if not character then
		return false
	end

	local Humanoid = character:FindFirstChildOfClass("Humanoid")
	return Humanoid ~= nil and Humanoid.Health > 0
end

function Functions:isClassMob(character: Model): boolean
	return not Players:GetPlayerFromCharacter(character)
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

function Functions:GetItemInfo(ItemEntry: Types.ItemData?): Types.Item?
	if not ItemEntry then
		return nil
	end

	local Info = ItemsData[ItemEntry.ID]
	if Info then
		return Info
	end

	return ItemsDataByName[ItemEntry.Name]
end

function Functions:GetEquippedItemInfo(PlayerData: Types.PlayerData, slot: string): Types.Item?
	local UUID = PlayerData.Equipment[slot]()
	if not UUID or UUID == "" then
		return nil
	end

	local ItemEntry = PlayerData.Inventory[UUID]()
	if not ItemEntry then
		return nil
	end

	return Functions:GetItemInfo(ItemEntry)
end

local function getTotalStats(Data: Types.PlayerData, StatName: string)
	local Stat = 0
	for _, Item in Data.Equipment do
		local KeyEntry = Data.Inventory[Item]
		if not KeyEntry then
			continue
		end

		local ItemInfo = Functions:GetItemInfo(KeyEntry) :: Types.Equipment
		if ItemInfo then
			local StatValue = ItemInfo.Stats[StatName]

			if not NON_UPGRADABLE_STATS[StatName] then
				StatValue *= 1 + (KeyEntry.Upgrades or 0) * 0.1
			end

			Stat += StatValue
		end
	end

	if Data.ExtraStats[StatName] then
		Stat += Data.ExtraStats[StatName]
	end

	return Stat
end

function Functions:GetTotalStats(entity: Model, Data: Types.PlayerData): Types.Stats
	if entity then
		local isMob = not Players:GetPlayerFromCharacter(entity)
		if isMob then
			local MobsData = require(ReplicatedStorage.Shared.MobsData)
			return MobsData[entity.Name] and MobsData[entity.Name].Data.Stats
		else
			return {
				Attack = getTotalStats(Data, "Attack"),
				Defense = getTotalStats(Data, "Defense"),
				Critical = getTotalStats(Data, "Critical"),
				Health = getTotalStats(Data, "Health"),
				Speed = getTotalStats(Data, "Speed"),
			}
		end
	end

	return {
		Attack = 0,
		Defense = 0,
		CriticalChance = 0,
		Luck = 0,
		Health = 0,
		Speed = 0,
	}
end

function Functions:GetXPNeeded(level: number): number
	if level >= 1300 then
		return 1000 * (level + 1) * 2 * (level + 1) * 2 - 1000 * (level + 1)
	end

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
		local HighestDamage = -1
		local HighestPlayer = nil

		for player, damage in hitlist do
			local Character = player.Character
			if not Character or not self:isEntityAlive(Character) then
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

function Functions:RollAttack(attackTable: { [string]: number })
	local totalWeight = 0
	for _, chance in attackTable do
		totalWeight += chance
	end

	local roll = math.random() * totalWeight

	local current = 0

	for attack, weight in attackTable do
		if weight > 0 then
			current += weight

			if roll <= current then
				return attack
			end
		end
	end

	return nil
end

function Functions:Raycast(origin: Vector3, direction: Vector3, params: RaycastParams?): RaycastResult?
	return workspace:Raycast(origin, direction, params)
end

function Functions:GetGroundCFrame(
	position: Vector3,
	ignoreList: { Instance }?,
	maxDistance: number?,
	keepRotation: CFrame?
): CFrame
	local Distance = maxDistance or 300
	local Origin = position + Vector3.new(0, Distance * 0.5, 0)
	local Direction = Vector3.new(0, -Distance, 0)

	local FilterList: { Instance } = {}

	if ignoreList then
		for _, instance in ignoreList do
			table.insert(FilterList, instance)
		end
	end

	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = FilterList
	Params.IgnoreWater = true

	local Result: RaycastResult? = nil
	local Guard = 0
	local MAX_ATTEMPTS = 25

	repeat
		Guard += 1
		Result = self:Raycast(Origin, Direction, Params)

		if
			Result
			and Result.Instance
			and Result.Instance:IsA("BasePart")
			and Result.Instance.CollisionGroup == ENTITY_COLLISION_GROUP
		then
			table.insert(FilterList, Result.Instance)
			Params.FilterDescendantsInstances = FilterList
			Result = nil
		end
	until Result ~= nil or Guard >= MAX_ATTEMPTS

	local RotationOnly = keepRotation and (keepRotation - keepRotation.Position) or CFrame.new()

	if Result then
		return CFrame.new(Result.Position) * RotationOnly
	end

	return CFrame.new(position) * RotationOnly
end

function Functions:TypeWrite(Label: TextLabel, Text: string)
	Label.MaxVisibleGraphemes = 0
	Label.Text = Text

	for i = 1, #Text do
		Label.MaxVisibleGraphemes = i
	end

	task.wait(3)

	for i = #Text, 0, -1 do
		Label.MaxVisibleGraphemes = i
	end
end

function Functions.FormatTime(seconds: number): string
	if seconds < 60 then
		return math.floor(seconds) .. "s"
	elseif seconds < 3600 then
		return (string.format("%.1f", seconds / 60):gsub("%.0$", "")) .. "m"
	elseif seconds < 86400 then
		return (string.format("%.1f", seconds / 3600):gsub("%.0$", "")) .. "h"
	else
		return (string.format("%.1f", seconds / 86400):gsub("%.0$", "")) .. "d"
	end
end

return Functions
