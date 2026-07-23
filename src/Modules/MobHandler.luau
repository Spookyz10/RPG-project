local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local InventoryManager = require(script.Parent.InventoryManager)
local RewardManager = require(script.Parent.RewardManager)
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
			Stats = MobInfo.Data.Stats,
			Model = MobModel,
			HitList = {},
			Buffs = {},
		})
	end
end

function MobHandler:RemoveMob(mobInfo: Types.Entity)
	local MobModel = mobInfo.Model
	local UUID = MobModel:FindFirstChild("UUID")
	MobClass:removeMob(UUID.Value)
	MobModel:Destroy()
end

for _, mobPart: BasePart in workspace:FindFirstChild("mobSpawns"):GetDescendants() do
	if mobPart:IsA("BasePart") then
		local value = Instance.new("StringValue")
		value.Name = "ID"
		value.Parent = mobPart
		MobHandler:AddMob(mobPart.Name)
	end
end

MobClass.Died:Connect(function(mob: Types.Entity, hitlist: { [Player]: number })
	local MobName = mob.Model.Name
	local MobInfo = MobsData[MobName] :: Types.MobInfo
	if not MobInfo then
		print("No mob info for mob: ", MobName, MobInfo)
		return
	end

	MobHandler:RemoveMob(mob)

	for player, _ in hitlist do
		local results = RewardManager:RollTable(MobInfo.Drops, player)
		for item, amount in results do
			InventoryManager:AddItem(player, item, amount)
		end
	end

	task.delay(MobInfo.RespawnTime or 5, function()
		MobHandler:AddMob(MobName)
	end)
end)

return MobHandler
