local definitions = {}
for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") then definitions[module.Name] = require(module) end
end
return definitions
