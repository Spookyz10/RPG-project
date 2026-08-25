local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Dialogue: Types.Dialogue = {

	GetStartNode = function(PlayerData: Types.PlayerData): string
		local Active = PlayerData.Quests()

		if Active["Wolf Hunter"] then
			return "QuestIncomplete"
		end

		return "Start"
	end,

	Nodes = {

		Start = {
			Text = "Hey there, want to earn some easy cash?",
			Options = {
				{
					Text = "Of course! Who doesn't want to",
					Action = function(self, PlayerData, Goto, Close)
						Goto("Start2")
					end,
				},
				{
					Text = "No thank you",
					Action = function(self, PlayerData, Goto, Close)
						Goto("NoAnswer")
					end,
				},
			},
		},

		Start2 = {
			Text = "See those wolves? Go slash them to death.",
			Action = function(self, PlayerData, Goto, Close)
				RemoteManager.SendServerEvent("AcceptQuest", "Wolf Hunter")
				Close()
			end,
		},

		NoAnswer = {
			Text = "Alright, if you are ever interested i'll be always here!",
			Action = function(self, PlayerData, Goto, Close)
				Close()
			end,
		},
	},
}

return Dialogue
