local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Item: Types.Material = {
	Kind = "Material",
	Data = {
		ID = "Spore Silk", Name = "Spore Silk", ItemType = "Material", SubType = "Mob Material",
		Stackable = true, Cap = 99, Level = 1, Rarity = "Uncommon", SellsFor = 9,
		Description = "Fibrous strands gathered from Mosscaps.",
	},
}
return Item
