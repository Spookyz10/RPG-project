local Listener = {}

for _, remote in script:GetDescendants() do
	if remote:IsA("ModuleScript") then
		Listener[remote.Name] = require(remote)
	end
end

return Listener
