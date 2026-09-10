local Modules = {}
require(script.Parent.Bootstrap).Ensure()

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Modules[module.Name] = require(module)
	end
end

-- Initialize before publishing the module, so remote listeners cannot access unbound UI.
for _, name in { "Bars", "Buffs", "Currencies", "Buttons", "Inventory", "SkillSelector", "ZoneSelector", "Raids", "PlayerList", "Party", "Dialog", "Journal", "Crafting" } do
	local module = Modules[name]
	if module and module.Init then module.Init() end
end

return Modules
