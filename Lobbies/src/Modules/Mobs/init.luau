local behaviors = {}

for _, module in script.Behaviors:GetDescendants() do
	if module:IsA("ModuleScript") then
		behaviors[module.Name] = require(module)
	end
end

return behaviors
