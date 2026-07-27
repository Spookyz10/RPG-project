local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryManager = require(script.Parent.InventoryManager)
local Mobs = require(script.Parent.Mobs)
local RewardManager = require(script.Parent.RewardManager)
local MobClass = require(ReplicatedStorage.Shared.MobClass)

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

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

function MobHandler:AddMob(mobName: string)
	local MobModel = Functions:getMob(mobName)
	if not MobModel then
		print("No mob model found for: ", mobName)
		return
	end
	MobModel = MobModel:Clone()
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local MobInfo = MobsData[MobModel.Name] :: Types.MobInfo
	if not MobInfo then
		print("No mob info for mob: ", MobModel.Name, MobInfo)
		return
	end
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

function MobHandler:StartBehavior(mobModel: Model, class: Types.Entity)
	local data = Mobs[mobModel.Name]
	if data and data.Start then
		data:Start(mobModel, class)
	end
end

local function Reward(player: Player, MobInfo: Types.MobInfo)
	local results = RewardManager:RollTable(MobInfo.Drops, player)
	for item, amount in results do
		InventoryManager:AddItem(player, item, amount)
	end

	for currency, amount in MobInfo.Currencies do
		RewardManager:AddCurrency(player, currency, amount)
	end

	RewardManager:AddXP(player, MobInfo.XP)
end

function MobHandler:InitializeSpawns()
	for _, mobPart: BasePart in workspace:FindFirstChild("mobSpawns"):GetDescendants() do
		if mobPart:IsA("BasePart") then
			local value = Instance.new("StringValue")
			value.Name = "ID"
			value.Parent = mobPart
			MobHandler:AddMob(mobPart.Name)
		end
	end
end

MobClass.Died:Connect(function(mob: Types.Entity, hitlist: { [Player]: number })
	local MobName = mob.Model.Name
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local MobInfo = MobsData[MobName] :: Types.MobInfo
	if not MobInfo then
		print("No mob info for mob: ", MobName, MobInfo)
		return
	end

	MobHandler:RemoveMob(mob)

	if MobInfo.GlobalDrops then
		for _, player in Players:GetPlayers() do
			Reward(player, MobInfo)
		end
	else
		for player, _ in hitlist do
			Reward(player, MobInfo)
		end
	end

	task.delay(MobInfo.RespawnTime or 5, function()
		MobHandler:AddMob(MobName)
	end)
end)

return MobHandler
