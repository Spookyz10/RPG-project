-- Presentation and default lifetime; gameplay callbacks live only on the server.
return {
	Poison = { Duration = 10, Interval = 1, Category = "Debuff", Icon = "rbxassetid://6145145342", Attribute = "Poisoned", HealthBar = { Color = {145, 205, 65}, Label = "POISON", Priority = 10 }, Tags = { "Poison", "DamageOverTime" } },
	["Lure Jab"] = { Duration = 5, Category = "Debuff", Icon = "rbxassetid://6145145342", Property = "Defense", Operation = "Multiply", Value = 0.5, Tags = { "DefenseDown" } },
	Venom = { Duration = 6, Category = "Debuff", Icon = "rbxassetid://6145145342", Tags = { "Mark" } },
	Fury = { Category = "Buff", Icon = "rbxassetid://3500778015", MaxStacks = 2, Tags = { "Charge" } },
}
