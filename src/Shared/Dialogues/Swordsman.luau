local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Dialogue: Types.Dialogue = {

	Start = {
		Text = "Hah! Another weakling looking for training, I bet.",
		Next = "Choice",
	},

	Choice = {
		Text = "So, what do you want?",
		Options = {
			{
				Text = "Teach me something.",
				Next = "TeachResponse",
			},
			{
				Text = "Nothing, sorry.",
				Action = function(self, PlayerData, Goto, Close)
					Close()
				end,
			},
		},
	},

	TeachReponse = {
		Text = "You better not be weak and poor at the same time, here is what I can teach you.",
		Action = function(self, PlayerData, Goto, Close)
			Logic["Shop"].Open("MartialArtistShop")
			Close()
		end,
	},
}

return Dialogue
