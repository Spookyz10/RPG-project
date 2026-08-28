local items = {}

for _, item in script:GetDescendants() do
	if item:IsA("ModuleScript") then
		local ItemModule = require(item)
		items[ItemModule.Data.ID] = ItemModule
	end
end

return items
