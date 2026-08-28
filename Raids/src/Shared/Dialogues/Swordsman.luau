local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Dialogue: Types.Dialogue = {
	Nodes = {
		Start = {
			Text = "Ha! Let me guess... another weakling looking for training.",
			Next = "Choice",
		},

		Choice = {
			Text = "So, what do you want from me?",
			Options = {
				{ Text = "Teach me something.", Next = "TeachResponse" },
				{ Text = "Who said I'm weak?", Next = "Cocky" },
				{
					Text = "Never mind, sorry.",
					Action = function(self, PlayerData, Goto, Close)
						Close()
					end,
				},
			},
		},

		Cocky = {
			Text = "Relax, kid. Everyone who comes here is weak. The difference is whether they leave that way too.",
			Next = "Choice2",
		},

		Choice2 = {
			Text = "So, are you just going to stand there, or do you actually want to learn?",
			Options = {
				{ Text = "Alright, teach me.", Next = "TeachResponse" },
				{
					Text = "I'll think about it.",
					Action = function(self, PlayerData, Goto, Close)
						Close()
					end,
				},
			},
		},

		TeachResponse = {
			Text = "I just hope you're not weak and broke at the same time. Here's what I have to offer.",
			Action = function(self, PlayerData, Goto, Close)
				Logic["Shop"].Open("SwordsmanShop")
				Close()
			end,
		},
	},
}

return Dialogue
