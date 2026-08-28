local Modules = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Modules[module.Name] = require(module)
	end
end

return Modules
