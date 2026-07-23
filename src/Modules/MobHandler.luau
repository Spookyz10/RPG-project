local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MobClass = require(ReplicatedStorage.Shared.MobClass)
local MobsData = require(ReplicatedStorage.Shared.MobsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local MobHandler = {}

local function getEmptySlot(mobName: string): BasePart?
	for _, spawnPart: BasePart in workspace:FindFirstChild("mobSpawns"):GetDescendants() do
		local ID = spawnPart:FindFirstChild("ID")
		if not ID then
			continue
		end

		if ID.Value == "" and spawnPart.Name == mobName then
			return spawnPart
		end
	end

	return nil
end

local function getMob(name: string)
	for _, mob: Model in ServerStorage:FindFirstChild("Mobs"):GetDescendants() do
		if mob:IsA("Model") and mob.Name == name then
			return mob
		end
	end

	return nil
end

function MobHandler:AddMob(mobName: string)
	local MobModel = getMob(mobName):Clone()
	local MobInfo = MobsData[MobModel.Name] :: Types.MobInfo
	local Origin = getEmptySlot(MobModel.Name)
	if Origin then
		MobModel.Parent = workspace:FindFirstChild("Mobs")
		MobModel:PivotTo(Origin.CFrame)

		MobClass.addMob({
			HP = MobInfo.HP,
			MaxHP = MobInfo.MaxHP,
			Data = { Stats = MobInfo.Data.Stats, HitList = {} },
			Model = MobModel,
			isPlayer = false,
		})
	end
end

for _, mobPart: BasePart in workspace:FindFirstChild("mobSpawns"):GetDescendants() do
	if mobPart:IsA("BasePart") then
		local value = Instance.new("StringValue")
		value.Name = "ID"
		value.Parent = mobPart
		MobHandler:AddMob(mobPart.Name)
	end
end

return MobHandler
