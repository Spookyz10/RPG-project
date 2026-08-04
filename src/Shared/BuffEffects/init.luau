local Effects = {}

for _, effect in script:GetDescendants() do
	if effect:IsA("ModuleScript") then
		Effects[effect.Name] = require(effect)
	end
end

return Effects
