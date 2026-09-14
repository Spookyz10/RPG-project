local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Dialogue: Types.Dialogue = {
	GetStartNode = function(PlayerData: Types.PlayerData): string
		if PlayerData.Quests()["Weakened Knight"] then
			return "InProgress"
		end
		if PlayerData.Level() < 12 then
			return "Unready"
		end
		if PlayerData.CompletedQuests()["Weakened Knight"] then
			return "Repeat"
		end
		return "Start"
	end,

	Nodes = {
		Unready = {
			Text = "The cave behind me is no place for an inexperienced fighter. Hunt Bushlings near the entrance, then Wolves and Boars farther into the Grasslands. Return when you reach level 12.",
			Options = {
				{ Text = "What should I prepare?", Next = "Preparation" },
				{ Text = "I will return stronger", Next = "Leave" },
			},
		},

		Preparation = {
			Text = "Bring a better weapon and something to keep you alive. The blacksmith can turn ivy, fangs, tusks, and bones into equipment. Learn to read attack indicators before entering the cave. (Level 12+)",
			Next = "Unready",
		},

		Start = {
			Text = "Stop for a moment. The cave behind me is not safe, and I would rather not watch another traveler walk in without knowing why.",
			Options = {
				{ Text = "What happened to you?", Next = "Story" },
				{ Text = "What do you need?", Next = "Mission" },
				{ Text = "Sorry, I cannot help", Next = "Leave" },
			},
		},

		Story = {
			Text = 'My patrol came here to clear the cave. A <shake><font color="#FF6F76"><b>Dire Bear</b></font></shake> rushed us from the dark before we could form a line. I made it back outside, but the others did not.',
			Next = "Mission",
		},

		Mission = {
			Text = 'The <shake><font color="#FF6F76"><b>Dire Bear</b></font></shake> is still inside. Kill it before it leaves this cave and finds the road. I cannot fight in this condition, but I can pay you for finishing the job.',
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
			Text = 'The <shake><font color="#FF6F76"><b>Dire Bear</b></font></shake> is still in the cave behind me. Be patient, watch its attacks, and come back alive.',
		},

		Repeat = {
			Text = 'The cave is quiet for now, but I can hear something moving in the deeper tunnels. If the <shake><font color="#FF6F76"><b>Dire Bear</b></font></shake> returns, will you face it again?',
			Options = {
				{ Text = "I will handle it", Next = "Mission" },
				{ Text = "Not right now", Next = "Leave" },
			},
		},

		Leave = {
			Text = "I understand. Do not face that beast until you are ready.",
		},
	},
}

return Dialogue
