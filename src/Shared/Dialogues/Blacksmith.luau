local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Dialogue: Types.Dialogue = {
	Nodes = {
		Start = {
			Text = "Hah, another one covered in dirt and scratches. What brings you to my forge?",
			Next = "Choice",
		},

		Choice = {
			Text = "Take a look around, I've got plenty to offer.",
			Options = {
				{ Text = "Enchants", Next = "Enchants" },
				{ Text = "Upgrades", Next = "Upgrades" },
				{ Text = "Crafting", Next = "CraftingOffer" },
				{
					Text = "Leave",
					Action = function(self, PlayerData, Goto, Close)
						Close()
					end,
				},
			},
		},

		Enchants = {
			Text = "Enchanting isn't ready yet, come back another time.",
			Next = "Choice",
		},

		Upgrades = {
			Text = "Upgrades aren't ready yet, I'm still setting things up.",
			Next = "Choice",
		},

		CraftingOffer = {
			Text = "If you've got the materials and the blueprint, I can get you crafting right away.",
			Action = function(self, PlayerData, Goto, Close)
				UIFunctions:OpenUI("Crafting")
				Close()
			end,
		},
	},
}

return Dialogue
