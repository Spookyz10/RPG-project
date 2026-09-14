local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Item: Types.Material = {
	Kind = "Material",
	Data = {
		ID = "Elder Heartwood", Name = "Elder Heartwood", ItemType = "Material", SubType = "Mob Material",
		Stackable = true, Cap = 99, Level = 1, Rarity = "Epic", SellsFor = 45,
		Description = "Ancient heartwood from Elderbark.",
	},
}
return Item
