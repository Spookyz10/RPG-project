local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryManager = require(script.Parent.InventoryManager)
local Mobs = require(script.Parent.Mobs)
local RewardManager = require(script.Parent.RewardManager)
local QuestManager = require(script.Parent.QuestManager)
local BehaviorManager = require(script.Parent.Mobs.BehaviorManager)
local StatusEffectManager = require(script.Parent.StatusEffectManager)
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

		if ID.Value == "" and spawnPart.Name == mobName and (spawnPart:GetAttribute("RespawnAt") or 0) <= workspace:GetServerTimeNow() then
			return spawnPart
		end
	end

	return nil
end

local function Reward(player: Player, MobInfo: Types.MobInfo, MobName: string, dropPosition: Vector3)
	local results = RewardManager:RollTable(MobInfo.Drops, player)
	local received = {}

	for item, amount in results do
		local _, _, added = InventoryManager:AddItem(player, item, amount)
		if added and added > 0 then received[item] = added end
	end

	if next(received) then
		require(ReplicatedStorage.Shared.Utils.RemoteManager).SendClientEvent("LootReward", { Player = player }, received, dropPosition)
	end

	for currency, amount in MobInfo.Currencies do
		RewardManager:AddCurrency(player, currency, amount)
	end

	RewardManager:AddMisc(player, "Kills", 1)
	RewardManager:AddXP(player, MobInfo.XP, { ["MobData"] = MobInfo })
	QuestManager:OnMobKilled(player, MobName)
end

local DEATH_ANIMATION_DELAY = 1.35

local function SetServerNetworkOwnership(mobModel: Model)
	local RootPart = mobModel.PrimaryPart or mobModel:FindFirstChild("HumanoidRootPart")
	if not RootPart or not RootPart:IsA("BasePart") then
		return
	end

	pcall(function()
		RootPart:SetNetworkOwner(nil)
	end)
end

function MobHandler:RemoveMob(mobModel: Model)
	local Connection = DiedConnections[mobModel]
	if Connection then
		Connection:Disconnect()
		DiedConnections[mobModel] = nil
	end

	BehaviorManager:Cancel(mobModel)
	StatusEffectManager:ClearEntity(mobModel)
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

	task.delay(DEATH_ANIMATION_DELAY, function()
		if mobModel and mobModel.Parent then
			mobModel:Destroy()
		end
	end)
end

function MobHandler:OnMobDied(mobModel: Model)
	if mobModel:GetAttribute("DeathStarted") then return end
 mobModel:SetAttribute("DeathStarted", true)
 BehaviorManager:Cancel(mobModel)
 require(script.Parent.MobDeath):Play(mobModel)
 local MobName = mobModel.Name
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local MobInfo = MobsData[MobName] :: Types.MobInfo
	if not MobInfo then
		self:RemoveMob(mobModel)
		return
	end

	local HitList = mobModel:FindFirstChild("HitList")
	local dropPosition = mobModel:GetPivot().Position
	local spawnReference = mobModel:FindFirstChild("SpawnOrigin")
	local origin = spawnReference and spawnReference.Value
	if origin and mobModel:GetAttribute("IsBoss") then
		require(script.Parent.BossRespawn).Start(origin, MobInfo.RespawnTime or 30)
	end

	self:RemoveMob(mobModel)

	if MobInfo.GlobalDrops then
		for _, player in Players:GetPlayers() do
			Reward(player, MobInfo, MobName, dropPosition)
		end
	elseif HitList then
		for _, entry in HitList:GetChildren() do
			local player = Players:GetPlayerByUserId(tonumber(entry.Name))
			if player then
				Reward(player, MobInfo, MobName, dropPosition)
			end
		end
	end

	local remaining = origin and origin:GetAttribute("RespawnAt")
	task.delay(remaining and math.max(0, remaining - workspace:GetServerTimeNow()) or MobInfo.RespawnTime or 5, function()
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
	if not Mobs[mobName] then
		warn("[MobHandler] No registered behavior for " .. mobName)
		return nil
	end

	if not MobModel then
		return nil
	end
	MobModel = MobModel:Clone()
	local root = MobModel:FindFirstChild("HumanoidRootPart")
	local humanoid = MobModel:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid then
		warn("[MobHandler] " .. mobName .. " needs Humanoid and HumanoidRootPart")
		MobModel:Destroy()
		return nil
	end
	MobModel.PrimaryPart = root
	for _, part in MobModel:GetDescendants() do
		if part:IsA("BasePart") then part.Anchored = false end
	end
	humanoid.BreakJointsOnDeath = false
	humanoid.PlatformStand = false
	humanoid.Sit = false
	humanoid.AutoRotate = true
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local MobInfo = MobsData[MobModel.Name] :: Types.MobInfo
	if not MobInfo then
		return nil
	end
	local Origin = getEmptySlot(MobModel.Name)
	if Origin then
		local Config = require(ReplicatedStorage.Shared.MobCombatConfig)[MobModel.Name]
		if Config then
			if Config.Height then
				MobModel:ScaleTo(MobModel:GetScale() * Config.Height / MobModel:GetExtentsSize().Y)
			end
			local Humanoid = MobModel:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.MaxHealth = Config.Health
				Humanoid.Health = Config.Health
				Humanoid.WalkSpeed = Config.Speed
			end
		end
		MobModel.Parent = workspace:FindFirstChild("Mobs")
		MobModel:SetAttribute("IsBoss", mobName == "Dire Bear")
		MobModel:SetAttribute("Level", MobInfo.Level)
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		local spawnReference = Instance.new("ObjectValue")
		spawnReference.Name = "SpawnOrigin"
		spawnReference.Value = Origin
		spawnReference.Parent = MobModel
		MobModel:PivotTo(Origin.CFrame)
		CollisionGroups:Apply(MobModel)
		SetServerNetworkOwnership(MobModel)

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
		if Config then
			task.spawn(function()
				while MobModel.Parent and Functions:isEntityAlive(MobModel) do
					if not BehaviorManager.Active[MobModel] and Functions:GetTargetPlayer(MobModel) then
						MobHandler:StartBehavior(MobModel)
					end
					task.wait(1)
				end
			end)
		end
	else
		MobModel:Destroy()
		return nil
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
	if not workspace:FindFirstChild("MobSpawns") then return end
	if not workspace:FindFirstChild("Mobs") then
		local folder = Instance.new("Folder"); folder.Name = "Mobs"; folder.Parent = workspace
	end
	for _, mobPart: BasePart in workspace:FindFirstChild("MobSpawns"):GetDescendants() do
		if mobPart:IsA("BasePart") then
			local value = mobPart:FindFirstChild("ID") or Instance.new("StringValue")
			value.Name = "ID"
			value.Parent = mobPart
			value.Value = ""
			MobHandler:AddMob(mobPart.Name)
		end
	end
end

return MobHandler
