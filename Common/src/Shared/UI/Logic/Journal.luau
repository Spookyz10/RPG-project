local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Templates = require(UI.Bootstrap).GetTemplates()
local T = require(UI.Theme)
local Quests = require(UI.Parent.QuestsData)
local Remotes = require(UI.Parent.Utils.RemoteManager)
local Journal = {}

function Journal.Init()
	local container = Constants.PlayerGui.Journal.Main.Body.Content.Container
	local function refresh()
		for _, child in container:GetChildren() do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		local count = 0
		for name, progress in Constants.Data.Quests() do
			local info = Quests[name]
			if not info then continue end
			count += 1
			local card = Templates.QuestTemplate:Clone()
			card.Name = name
			local height = 194 + #info.Objectives * 28
			card.Size = UDim2.fromScale(0.98, height / 470)
			card.QuestName.Text = info.Name or name
			card.Description.Text = info.Description
			card.Parent = container
			for index, objective in info.Objectives do
				local amount = (progress.Objectives or {})[index] or 0
				local label = card.ObjectiveTemplate:Clone()
				label.Name = "Objective" .. index
				label.Text = objective.Target .. "  " .. math.min(amount, objective.Amount) .. " / " .. objective.Amount
				label.Position = UDim2.fromScale(0.03, (110 + (index - 1) * 28) / height)
				label.Visible = true
				label.Parent = card
			end
			local abandon = card.Abandon
			local confirm = false
			abandon.Activated:Connect(function()
				if not confirm then
					confirm = true
					abandon.Text = "Tap again to abandon"
					task.delay(3, function() confirm = false; if abandon.Parent then abandon.Text = "Abandon quest" end end)
					return
				end
				Remotes.SendServerEvent("AbandonQuest", name)
			end)
		end
		if count == 0 then
			local empty = Templates.EmptyTemplate:Clone()
			empty.Text = "A new story starts with a conversation.\nTalk to a villager to pick up a quest."
			empty.Parent = container
		end
	end
	Constants.Data.Quests.Changed(refresh)
	refresh()
end

return Journal
