local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Item: Types.Material = {
	Kind = "Material",
	Data = {
		ID = "Thorn Antler", Name = "Thorn Antler", ItemType = "Material", SubType = "Mob Material",
		Stackable = true, Cap = 99, Level = 1, Rarity = "Uncommon", SellsFor = 13,
		Description = "A branching antler shed by a Thornback Stag.",
	},
}
return Item
