local skills = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		skills[module.Name] = require(module)
	end
end

return skills
