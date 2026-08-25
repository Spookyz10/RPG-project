local items = {}

for _, item in script:GetDescendants() do
	if item:IsA("ModuleScript") then
		items[item.Name] = require(item)
	end
end

return items
