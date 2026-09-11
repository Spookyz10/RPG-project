-- Shared by damage presentation; new damage types need only a style entry.
local Styles = {
	Normal = { Color = Color3.fromRGB(255, 169, 92), Stroke = Color3.fromRGB(82, 35, 18), Template = "Base" },
	Critical = { Color = Color3.fromRGB(195, 112, 255), Stroke = Color3.fromRGB(65, 24, 100), Template = "Crit" },
	Bleed = { Color = Color3.fromRGB(255, 68, 100), Stroke = Color3.fromRGB(91, 13, 40), Template = "Base" },
	Poison = { Color = Color3.fromRGB(164, 242, 65), Stroke = Color3.fromRGB(36, 69, 16), Template = "Base" },
	Heal = { Color = Color3.fromRGB(69, 242, 168), Stroke = Color3.fromRGB(15, 79, 59), Template = "Heal" },
}
local Aliases = { base = "Normal", normal = "Normal", crit = "Critical", critical = "Critical", bleed = "Bleed", poison = "Poison", heal = "Heal" }
return {
	Resolve = function(name)
		local id = Aliases[string.lower(name or "Normal")] or "Normal"
		return Styles[id], id
	end,
}
