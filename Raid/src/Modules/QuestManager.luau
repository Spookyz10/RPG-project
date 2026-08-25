local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local QuestsData = require(ReplicatedStorage.Shared.QuestsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local RewardManager = require(script.Parent.RewardManager)
local InventoryManager = require(script.Parent.InventoryManager)
local RecipeManager = require(script.Parent.RecipeManager)

local QuestManager = {}

function QuestManager:GetQuestInfo(questName: string): Types.QuestInfo?
	return QuestsData[questName]
end

function QuestManager:IsQuestCompleted(PlayerData: Types.PlayerData, questName: string): boolean
	local Entry = PlayerData.CompletedQuests()[questName]
	return Entry ~= nil and Entry.Count > 0
end

function QuestManager:CanAcceptQuest(PlayerData: Types.PlayerData, questName: string): (boolean, string)
	local QuestInfo = QuestsData[questName] :: Types.QuestInfo
	if not QuestInfo then
		return false, "Quest not found"
	end

	if PlayerData.Quests()[questName] then
		return false, "Quest already active"
	end

	if QuestInfo.RequiredLevel and PlayerData.Level() < QuestInfo.RequiredLevel then
		return false, "Level too low"
	end

	if QuestInfo.RequiredQuest and not self:IsQuestCompleted(PlayerData, QuestInfo.RequiredQuest) then
		return false, "Prerequisite quest not completed"
	end

	local CompletedEntry = PlayerData.CompletedQuests()[questName]
	if CompletedEntry then
		if not QuestInfo.Repeatable then
			return false, "Quest already completed"
		end

		if QuestInfo.Cooldown and (os.time() - CompletedEntry.LastCompletedAt) < QuestInfo.Cooldown then
			return false, "Quest is on cooldown"
		end
	end

	return true, "OK"
end

function QuestManager:BuildProgress(QuestInfo: Types.QuestInfo): Types.QuestProgress
	local Objectives = {}
	for index in QuestInfo.Objectives do
		Objectives[index] = 0
	end

	return {
		Objectives = Objectives,
		StartedAt = os.time(),
	}
end

function QuestManager:GrantRewards(player: Player, rewards: Types.QuestReward?)
	if not rewards then
		return
	end

	if rewards.Currencies then
		for currency, amount in rewards.Currencies do
			RewardManager:AddCurrency(player, currency, amount)
		end
	end

	if rewards.XP then
		RewardManager:AddXP(player, rewards.XP, { ["QuestInfo"] = rewards })
	end

	if rewards.Items then
		for itemName, amount in rewards.Items do
			InventoryManager:AddItem(player, itemName, amount)
		end
	end

	if rewards.Recipes then
		for _, recipeName in rewards.Recipes do
			RecipeManager:AddRecipe(recipeName, player)
		end
	end
end

function QuestManager:ForceCompleteQuest(player: Player, PlayerData: Types.PlayerData, questName: string)
	local QuestInfo = QuestsData[questName] :: Types.QuestInfo
	if not QuestInfo then
		return
	end

	PlayerData.Quests[questName](nil)

	local Existing = PlayerData.CompletedQuests()[questName]
	local NewCount = (Existing and Existing.Count or 0) + 1

	PlayerData.CompletedQuests[questName]({
		Count = NewCount,
		LastCompletedAt = os.time(),
	})

	self:GrantRewards(player, QuestInfo.Rewards)
end

function QuestManager:CheckCompletion(player: Player, PlayerData: Types.PlayerData, questName: string)
	local QuestInfo = QuestsData[questName] :: Types.QuestInfo
	if not QuestInfo then
		return
	end

	local Progress = PlayerData.Quests()[questName]
	if not Progress then
		return
	end

	for index, objective in QuestInfo.Objectives do
		if (Progress.Objectives[index] or 0) < objective.Amount then
			return
		end
	end

	self:ForceCompleteQuest(player, PlayerData, questName)
end

function QuestManager:AddObjectiveProgress(player: Player, objectiveType: string, target: string, amount: number)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local ActiveQuests = PlayerData.Quests()

	for questName, progress in ActiveQuests do
		local QuestInfo = QuestsData[questName] :: Types.QuestInfo
		if not QuestInfo then
			continue
		end

		local Changed = false
		local NewObjectives = table.clone(progress.Objectives)

		for index, objective in QuestInfo.Objectives do
			if objective.Type == objectiveType and objective.Target == target then
				local Current = NewObjectives[index] or 0
				if Current < objective.Amount then
					NewObjectives[index] = math.min(objective.Amount, Current + amount)
					Changed = true
				end
			end
		end

		if Changed then
			PlayerData.Quests[questName]({ Objectives = NewObjectives, StartedAt = progress.StartedAt })
			self:CheckCompletion(player, PlayerData, questName)
		end
	end
end

function QuestManager:OnMobKilled(player: Player, mobName: string)
	self:AddObjectiveProgress(player, "KillMob", mobName, 1)
end

function QuestManager:OnItemCrafted(player: Player, itemName: string)
	self:AddObjectiveProgress(player, "CraftItem", itemName, 1)
end

function QuestManager:GetPrerequisiteChain(questName: string): { string }
	local Chain = {}
	local Current = QuestsData[questName] :: Types.QuestInfo
	local Guard = 0

	while Current and Current.RequiredQuest and Guard < 25 do
		table.insert(Chain, 1, Current.RequiredQuest)
		Current = QuestsData[Current.RequiredQuest]
		Guard += 1
	end

	return Chain
end

function QuestManager:TryAutoCompleteChain(player: Player, PlayerData: Types.PlayerData, questName: string)
	for _, prereqName in self:GetPrerequisiteChain(questName) do
		if self:IsQuestCompleted(PlayerData, prereqName) then
			continue
		end

		local PrereqInfo = QuestsData[prereqName] :: Types.QuestInfo
		if not PrereqInfo or not PrereqInfo.SkipIfOverleveled then
			return
		end

		if PlayerData.Level() <= (PrereqInfo.RequiredLevel or 0) then
			return
		end

		self:ForceCompleteQuest(player, PlayerData, prereqName)
	end
end

function QuestManager:AcceptQuest(player: Player, questName: string, skipChain: boolean?): (boolean, string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data"
	end

	if not QuestsData[questName] then
		return false, "Quest not found"
	end

	if skipChain then
		self:TryAutoCompleteChain(player, PlayerData, questName)
	end

	local CanAccept, Reason = self:CanAcceptQuest(PlayerData, questName)
	if not CanAccept then
		return false, Reason
	end

	local QuestInfo = QuestsData[questName] :: Types.QuestInfo
	PlayerData.Quests[questName](self:BuildProgress(QuestInfo))

	return true, "Quest accepted"
end

function QuestManager:AbandonQuest(player: Player, questName: string): (boolean, string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data"
	end

	if not PlayerData.Quests()[questName] then
		return false, "Quest not active"
	end

	PlayerData.Quests[questName](nil)
	return true, "Quest abandoned"
end

return QuestManager
