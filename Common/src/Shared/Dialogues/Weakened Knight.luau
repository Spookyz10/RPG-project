local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Dialogue: Types.Dialogue = {
	GetStartNode = function(PlayerData: Types.PlayerData): string
		if PlayerData.Quests()["Weakened Knight"] then
			return "InProgress"
		end
		if PlayerData.CompletedQuests()["Weakened Knight"] then
			return "Completed"
		end
		return "Start"
	end,

	Nodes = {
		Start = {
			Text = "Hold on. You look like you can handle yourself. I need a favor, if you are willing to hear me out.",
			Options = {
				{ Text = "What happened to you?", Next = "Story" },
				{ Text = "What do you need?", Next = "Mission" },
				{ Text = "Sorry, I cannot help", Next = "Leave" },
			},
		},

		Story = {
			Text = "A Dire Bear caught my patrol near the end of the Village Outskirts. I survived, but the others were not as lucky. The beast is still there.",
			Next = "Mission",
		},

		Mission = {
			Text = "Kill the <font color=\"#FF6F76\"><b>Dire Bear</b></font> before it reaches another patrol. I cannot fight in this condition, but I can pay you for finishing the job.",
			Options = {
				{
					Text = "I will take care of it",
					Action = function(self, PlayerData, Goto, Close)
						RemoteManager.SendServerEvent("AcceptQuest", "Weakened Knight")
						Close()
					end,
				},
				{ Text = "Where can I find it?", Next = "Location" },
				{ Text = "I am not ready", Next = "Leave" },
			},
		},

		Location = {
			Text = "Enter the Village Outskirts and follow the path to the cave at the far end. You will know you are close when the smaller animals stop making noise.",
			Next = "Mission",
		},

		InProgress = {
			Text = "The Dire Bear is still near the cave at the end of the Village Outskirts. Be patient, watch its attacks, and come back alive.",
		},

		Completed = {
			Text = "I heard the Dire Bear is dead. You did what I could not. Thank you. The road is safer because of you.",
		},

		Leave = {
			Text = "I understand. Do not face that beast until you are ready.",
		},
	},
}

return Dialogue
