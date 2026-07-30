local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Dialogue: Types.Dialogue = {

	Start = {
		Text = "Welcome, traveler! I'm here to help newcomers find their footing in this world.",
		Next = "LevelInfo",
	},

	LevelInfo = {
		Text = function(PlayerData: Types.PlayerData)
			return "You're currently level "
				.. PlayerData.Level()
				.. ". Fight nearby creatures to gain experience and grow stronger."
		end,
		Next = "Choice",
	},

	Choice = {
		Text = "Anything else?",
		Options = {
			{
				Text = "You look stupid",
				Action = function(self, PlayerData, Goto, Close)
					Goto("RelaxedTip")
				end,
			},
			{
				Text = "I'm looking for a challenge.",
				Condition = function(PlayerData: Types.PlayerData)
					return PlayerData.Level() >= 5
				end,
				Action = function(self, PlayerData, Goto, Close)
					Goto("DiligentTip")
				end,
			},
			{
				Text = "No thanks, I'm good.",
				Action = function(self, PlayerData, Goto, Close)
					Close()
				end,
			},
		},
	},

	RelaxedTip = {
		Text = "ehkp me",
		Next = "Reward",
	},

	DiligentTip = {
		Text = "Seek out the Bear and the Boar further out. Their drops are worth the risk.",
		Next = "Reward",
	},

	Reward = {
		Text = "Take this as a token of my appreciation.",
		Options = {
			{
				Text = "Thank you!",
				Action = function(self, PlayerData, Goto, Close)
					RemoteManager.SendServerEvent("CompleteTutorial")
					Close()
				end,
			},
		},
	},
}

return Dialogue
