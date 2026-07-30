local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Dialogue: Types.Dialogue = {

	Start = {
		Text = "Hey there, you look confused, perhaps are you new here?",
		Options = {
			{
				Text = "Yeah I'm lost!",
				Action = function(self, PlayerData, Goto, Close)
					Goto("Start2")
				end,
			},
			{
				Text = "No.",
				Action = function(self, PlayerData, Goto, Close)
					Goto("NoAnswer")
				end,
			},
		},
	},

	Start2 = {
		Text = "So I was right! Welcome to Fuji then! We are a small community here in the north of Syphon, I will teach you how to get around this place",
		Next = "LevelInfo",
	},

	NoAnswer = {
		Text = "Oh, I'm sorry! If you ever need a guide talk to me! I might even reward you!",
		Action = function(self, PlayerData, Goto, Close)
			Close()
		end,
	},

	LevelInfo = {
		Text = function(PlayerData: Types.PlayerData)
			if PlayerData.Level() > 1 then
				return "It seems like you are already Level "
					.. PlayerData.Level()
					.. ". You must be already very experienced in fighting!."
			else
				return "You're currently level "
					.. PlayerData.Level()
					.. ". You need to fight enemies at zones to earn experience and get stronger."
			end
		end,
		Next = function(PlayerData: Types.PlayerData)
			if PlayerData.Level() > 1 then
				return "strong"
			else
				return "starter"
			end
		end,
	},

	strong = {
		Text = "Because of that let's skip the first quest and give you the rewards upfront, Your next goal now is to kill the Bear, beware as he has special attacks that are dangerous! Watch out for red indicators.",
		Action = function(self, PlayerData, Goto, Close)
			RemoteManager.SendServerEvent("AcceptQuest", "Tutorial2", true)
			Close()
		end,
	},

	starter = {
		Text = "Your first goal is to defeat 3 bushlings, they are the weakest enemy in the world so it shouldn't be hard! Go to the blue portal and enter the 'Village Outskirts' zone, they should be the first enemies you encounter.",
		Action = function(self, PlayerData, Goto, Close)
			RemoteManager.SendServerEvent("AcceptQuest", "Tutorial1")
			Close()
		end,
	},

	QuestIncomplete = {
		Text = "Hey there, need anything?",
		Options = {
			{
				Text = "What do I do?",
				Action = function(self, PlayerData, Goto, Close)
					Goto("QuestExplanation")
				end,
			},
			{
				Text = "Nevermind",
				Action = function(self, PlayerData, Goto, Close)
					Close()
				end,
			},
		},
	},

	QuestExplanation = {
		Text = function(PlayerData: Types.PlayerData)
			local Quests = PlayerData.Quests()
			if Quests["Tutorial1"] then
				return "Remember, go to the blue portal accross the river, select the first zone by clicking on it, and then click the 'Enter' button"
			elseif Quests["Tutorial2"] then
				return "Go back there and kill the Bear boss, after you do so come back, you can find it at the cave which is located at the end of the zone"
			else
				return "Go to the blacksmith, select the Fang Dagger item and craft it, the blacksmith is right there next!"
			end
		end,
	},

	Quest1Done = {
		Text = "Congratulations on learning the basics of the world",
	},
}

return Dialogue
