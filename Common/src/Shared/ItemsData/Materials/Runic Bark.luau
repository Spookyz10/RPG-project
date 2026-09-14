local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Item: Types.Material = {
	Kind = "Material",
	Data = {
		ID = "Runic Bark", Name = "Runic Bark", ItemType = "Material", SubType = "Mob Material",
		Stackable = true, Cap = 99, Level = 1, Rarity = "Rare", SellsFor = 18,
		Description = "Inscribed bark recovered from Hollow Sentinels.",
	},
}
return Item
