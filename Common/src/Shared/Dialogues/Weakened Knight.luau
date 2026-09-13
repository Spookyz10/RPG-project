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
			Text = "Stop for a moment. The cave behind me is not safe, and I would rather not watch another traveler walk in without knowing why.",
			Options = {
				{ Text = "What happened to you?", Next = "Story" },
				{ Text = "What do you need?", Next = "Mission" },
				{ Text = "Sorry, I cannot help", Next = "Leave" },
			},
		},

		Story = {
			Text = "My patrol came here to clear the cave. A <shake><font color=\"#FF6F76\"><b>Dire Bear</b></font></shake> rushed us from the dark before we could form a line. I made it back outside, but the others did not.",
			Next = "Mission",
		},

		Mission = {
			Text = "The <shake><font color=\"#FF6F76\"><b>Dire Bear</b></font></shake> is still inside. Kill it before it leaves this cave and finds the road. I cannot fight in this condition, but I can pay you for finishing the job.",
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
			Text = "You are standing at the entrance. Go inside and stay alert. The deeper tunnels are quiet, but that does not mean they are empty.",
			Next = "Mission",
		},

		InProgress = {
			Text = "The <shake><font color=\"#FF6F76\"><b>Dire Bear</b></font></shake> is still in the cave behind me. Be patient, watch its attacks, and come back alive.",
		},

		Completed = {
			Text = "The cave is quiet at last. You did what I could not. Thank you. The road is safer because of you.",
		},

		Leave = {
			Text = "I understand. Do not face that beast until you are ready.",
		},
	},
}

return Dialogue
