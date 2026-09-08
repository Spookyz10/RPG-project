local AttackStyles = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		AttackStyles[module.Name] = require(module)
	end
end

return AttackStyles
