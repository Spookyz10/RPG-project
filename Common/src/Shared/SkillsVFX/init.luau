local VFXModules = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		VFXModules[module.Name] = require(module)
	end
end

return VFXModules
