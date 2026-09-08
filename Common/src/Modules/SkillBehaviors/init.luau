local SkillBehaviors = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		SkillBehaviors[module.Name] = require(module)
	end
end

return SkillBehaviors
