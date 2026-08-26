local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryManager = require(script.Parent.InventoryManager)
local Mobs = require(script.Parent.Mobs)
local RewardManager = require(script.Parent.RewardManager)
local QuestManager = require(script.Parent.QuestManager)
local BehaviorManager = require(script.Parent.Mobs.BehaviorManager)
local BuffsManager = require(script.Parent.BuffsManager)
local CooldownSystem = require(script.Parent.CooldownSystem)
local CollisionGroups = require(ReplicatedStorage.Shared.CollisionGroups)

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local MobHandler = {}

local DiedConnections: { [Model]: RBXScriptConnection } = {}

local function getEmptySlot(mobName: string): BasePart?
	for _, spawnPart: BasePart in workspace:FindFirstChild("MobSpawns"):GetDescendants() do
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

local function Reward(player: Player, MobInfo: Types.MobInfo, MobName: string)
	local results = RewardManager:RollTable(MobInfo.Drops, player)

	for item, amount in results do
		InventoryManager:AddItem(player, item, amount)
	end

	for currency, amount in MobInfo.Currencies do
		RewardManager:AddCurrency(player, currency, amount)
	end

	RewardManager:AddMisc(player, "Kills", 1)
	RewardManager:AddXP(player, MobInfo.XP, { ["MobData"] = MobInfo })
	QuestManager:OnMobKilled(player, MobName)
end

function MobHandler:RemoveMob(mobModel: Model)
	local Connection = DiedConnections[mobModel]
	if Connection then
		Connection:Disconnect()
		DiedConnections[mobModel] = nil
	end

	BehaviorManager:Cancel(mobModel)
	BuffsManager:ClearEntity(mobModel)
	CooldownSystem:ResetAllCooldowns(mobModel)

	local UUID = mobModel:FindFirstChild("UUID")

	for _, spawnPart: BasePart in workspace:FindFirstChild("MobSpawns"):GetDescendants() do
		local ID = spawnPart:FindFirstChild("ID")
		if not ID then
			continue
		end

		if UUID and ID.Value == UUID.Value then
			ID.Value = ""
			break
		end
	end

	mobModel:Destroy()
end

function MobHandler:OnMobDied(mobModel: Model)
	local MobName = mobModel.Name
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local MobInfo = MobsData[MobName] :: Types.MobInfo
	if not MobInfo then
		self:RemoveMob(mobModel)
		return
	end

	local HitList = mobModel:FindFirstChild("HitList")

	self:RemoveMob(mobModel)

	if MobInfo.GlobalDrops then
		for _, player in Players:GetPlayers() do
			Reward(player, MobInfo, MobName)
		end
	elseif HitList then
		for _, entry in HitList:GetChildren() do
			local player = Players:GetPlayerByUserId(tonumber(entry.Name))
			if player then
				Reward(player, MobInfo, MobName)
			end
		end
	end

	task.delay(MobInfo.RespawnTime or 5, function()
		MobHandler:AddMob(MobName)
	end)
end

function MobHandler:AddMob(mobName: string | { string }): Model?
	if typeof(mobName) == "table" then
		for _, name in mobName do
			MobHandler:AddMob(name)
		end
		return nil
	end

	local MobModel = Functions:getMob(mobName)

	if not MobModel then
		return nil
	end
	MobModel = MobModel:Clone()
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local MobInfo = MobsData[MobModel.Name] :: Types.MobInfo
	if not MobInfo then
		return nil
	end
	local Origin = getEmptySlot(MobModel.Name)
	if Origin then
		MobModel.Parent = workspace:FindFirstChild("Mobs")
		MobModel:PivotTo(Origin.CFrame)
		CollisionGroups:Apply(MobModel)

		local UUID = Instance.new("StringValue")
		UUID.Name = "UUID"
		UUID.Value = Functions:GenUUID()
		UUID.Parent = MobModel

		local HitList = Instance.new("Folder")
		HitList.Name = "HitList"
		HitList.Parent = MobModel

		local Humanoid = MobModel:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			DiedConnections[MobModel] = Humanoid.Died:Connect(function()
				MobHandler:OnMobDied(MobModel)
			end)
		end

		Origin:FindFirstChild("ID").Value = UUID.Value

		self:StartBehavior(MobModel)
	end

	return MobModel
end

function MobHandler:StartBehavior(mobModel: Model)
	local data = Mobs[mobModel.Name]
	if data and data.Start then
		task.spawn(function()
			data:Start(mobModel)
		end)
	end
end

function MobHandler:InitializeSpawns()
	for _, mobPart: BasePart in workspace:FindFirstChild("MobSpawns"):GetDescendants() do
		if mobPart:IsA("BasePart") then
			local value = Instance.new("StringValue")
			value.Name = "ID"
			value.Parent = mobPart
			value.Value = ""
			MobHandler:AddMob(mobPart.Name)
		end
	end
end

return MobHandler
