local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Dialogue: Types.Dialogue = {

	GetStartNode = function(PlayerData: Types.PlayerData): string
		local Active = PlayerData.Quests()
		local Completed = PlayerData.CompletedQuests()

		if Completed["Tutorial3"] then
			return "Quest1Done"
		end

		if Active["Tutorial1"] or Active["Tutorial2"] or Active["Tutorial3"] then
			return "QuestIncomplete"
		end

		if Completed["Tutorial2"] then
			return "OfferTutorial3"
		end

		if Completed["Tutorial1"] then
			return "OfferTutorial2"
		end

		return "Start"
	end,

	Nodes = {

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
					return "Remember, go to the blue portal accross the river, select the first zone by clicking on it, and then click the 'Enter' button. You need to defeat 3 Bushlings."
				elseif Quests["Tutorial2"] then
					return "Go back there and kill the Bear boss, after you do so come back, you can find it at the cave which is located at the end of the zone"
				elseif Quests["Tutorial3"] then
					return "Go to the blacksmith, select the Fang Dagger item and craft it, the blacksmith is right there next!"
				else
					return "I don't have anything else for you right now, come back if that changes!"
				end
			end,
		},

		OfferTutorial2 = {
			Text = "You handled those bushlings well! Your next goal is to kill the Bear, beware as he has special attacks that are dangerous! Watch out for red indicators.",
			Action = function(self, PlayerData, Goto, Close)
				RemoteManager.SendServerEvent("AcceptQuest", "Tutorial2")
				Close()
			end,
		},

		OfferTutorial3 = {
			Text = "You slew the Bear, impressive! Now go to the blacksmith, select the Fang Dagger item and craft it to finish your training.",
			Action = function(self, PlayerData, Goto, Close)
				RemoteManager.SendServerEvent("AcceptQuest", "Tutorial3")
				Close()
			end,
		},

		Quest1Done = {
			Text = "Congratulations on learning the basics of the world",
		},
	},
}

return Dialogue
