local Raids = {}

for _, raid in script:GetDescendants() do
	if raid:IsA("ModuleScript") then
		Raids[raid.Name] = require(raid)
	end
end

return Raids
