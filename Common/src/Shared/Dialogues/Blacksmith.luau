local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Dialogue: Types.Dialogue = {
	Nodes = {
		Start = {
			Text = "Need something? I can put the forge to work if you brought the right materials.",
			Options = {
				{
					Text = "I want to craft something",
					Action = function(self, PlayerData, Goto, Close)
						Close()
						UIFunctions:OpenUI("Crafting")
					end,
				},
				{ Text = "Your story?", Next = "Lore" },
				{ Text = "Do you have any advice?", Next = "Tips" },
				{
					Text = "Nothing right now",
					Action = function(self, PlayerData, Goto, Close)
						Close()
					end,
				},
			},
		},

		Lore = {
			Text = "My father taught me when I was young. Back then I only repaired farm tools. Adventurers like you started coming through Fuji however, broken swords kept piling up and because of that I learned quickly.",
			Next = "Start",
		},

		Tips = {
			Text = 'Keep every material you find until you know what it makes. A common trophy may be the last thing missing from a good weapon. Also, do not spend all your <font color="#FFD051"><b>gold</b></font> at once.',
			Next = "Start",
		},
	},
}

return Dialogue
