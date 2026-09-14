return {
	Nodes = {
		Start = {
			Text = "Welcome! Take a look around. Every adventure starts with a little preparation.",
			Options = {
				{
					Text = "Show me your wares",
					Action = function(self, PlayerData, Goto, Close)
						Close()
						require(game:GetService("ReplicatedStorage").Shared.UI.Logic.Shop).Open("Shop")
					end,
				},
				{
					Text = "Maybe later",
					Action = function(self, PlayerData, Goto, Close)
						Close()
					end,
				},
			},
		},
	},
}
