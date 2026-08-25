local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestsData = require(ReplicatedStorage.Shared.QuestsData)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local QuestFrames: { [string]: { Frame: Frame, Disconnectors: { () -> () } } } = {}
local CurrentQuestName: string? = nil
local RequirementDisconnect: (() -> ())? = nil

local ObjectiveVerbs = {
	KillMob = "Kill",
	CraftItem = "Craft",
}

local function GetObjectiveText(objective: Types.QuestObjective, current: number): string
	local Verb = ObjectiveVerbs[objective.Type] or objective.Type
	return Verb .. " " .. objective.Target .. " (" .. current .. "/" .. objective.Amount .. ")"
end

function UI.Init()
	local Data = UIConstants.Data

	local QuestsFrame = UIConstants.Main:WaitForChild("Quests")
	local List = QuestsFrame.List
	local Container = List.Container

	local InfoFrame = QuestsFrame.InfoFrame
	local Requirements = InfoFrame.Requirements
	local RequirementsInfo = Requirements.Info

	local QuestTemplate = ReplicatedStorage.Assets.UI.Templates.Quest
	local RequirementTemplate = ReplicatedStorage.Assets.UI.Templates.QuestRequirement

	local function CloseInfo()
		InfoFrame.Visible = false
		CurrentQuestName = nil

		if RequirementDisconnect then
			RequirementDisconnect()
			RequirementDisconnect = nil
		end
	end

	local function RenderRequirements(questName: string, Progress: Types.QuestProgress)
		local QuestInfo = QuestsData[questName] :: Types.QuestInfo
		if not QuestInfo then
			return
		end

		for _, child in RequirementsInfo:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		for index, objective in QuestInfo.Objectives do
			local Current = Progress.Objectives[index] or 0

			local Label = RequirementTemplate:Clone()
			Label.Text = GetObjectiveText(objective, Current)
			Label.Parent = RequirementsInfo
		end
	end

	local function OpenQuestInfo(questName: string)
		local QuestInfo = QuestsData[questName] :: Types.QuestInfo
		local Progress = Data.Quests()[questName]

		if not QuestInfo or not Progress then
			return
		end

		if RequirementDisconnect then
			RequirementDisconnect()
			RequirementDisconnect = nil
		end

		CurrentQuestName = questName

		InfoFrame.QuestName.Text = QuestInfo.Name
		InfoFrame.Description.Text = QuestInfo.Description

		RenderRequirements(questName, Progress)

		RequirementDisconnect = Data.Quests[questName].Changed(function(NewProgress)
			if NewProgress then
				RenderRequirements(questName, NewProgress)
			end
		end)

		InfoFrame.Visible = true
	end

	local function CreateQuestFrame(questName: string)
		if QuestFrames[questName] then
			return
		end

		local QuestInfo = QuestsData[questName] :: Types.QuestInfo
		if not QuestInfo then
			return
		end

		local Frame = QuestTemplate:Clone()
		Frame.Name = questName
		Frame.QuestName.Text = QuestInfo.Name
		Frame.Desc.Text = QuestInfo.Description

		local ClickConnection = Frame.Info.MouseButton1Click:Connect(function()
			OpenQuestInfo(questName)
		end)

		Frame.Parent = Container

		QuestFrames[questName] = {
			Frame = Frame,
			Disconnectors = {
				function()
					ClickConnection:Disconnect()
				end,
			},
		}
	end

	local function RemoveQuestFrame(questName: string)
		local Entry = QuestFrames[questName]
		if not Entry then
			return
		end

		for _, Disconnect in Entry.Disconnectors do
			Disconnect()
		end

		Entry.Frame:Destroy()
		QuestFrames[questName] = nil

		if CurrentQuestName == questName then
			CloseInfo()
		end
	end

	InfoFrame.Abadon.MouseButton1Click:Connect(function()
		if not CurrentQuestName then
			return
		end

		RemoteManager.SendServerEvent("AbandonQuest", CurrentQuestName)
		CloseInfo()
	end)

	InfoFrame.Close.MouseButton1Click:Connect(function()
		CloseInfo()
	end)

	InfoFrame.Visible = false

	for questName in Data.Quests() do
		CreateQuestFrame(questName)
	end

	Data.Quests.OnKeyAdded(function(questName)
		CreateQuestFrame(questName)
	end)

	Data.Quests.OnKeyRemoved(function(questName)
		RemoveQuestFrame(questName)
	end)
end

return UI
