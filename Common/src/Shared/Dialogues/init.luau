local Dialogues = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Dialogues[module.Name] = require(module)
	end
end

return Dialogues
