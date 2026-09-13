local registry = {}

for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		registry[module.Name] = require(module)
	end
end

return registry
