local items = {}
local byId = {}

for _, item in script:GetDescendants() do
	if item:IsA("ModuleScript") then
		local ItemModule = require(item)
		items[item.Name] = ItemModule

		if ItemModule.Data and ItemModule.Data.ID then
			byId[ItemModule.Data.ID] = ItemModule
		end
	end
end

items.ById = byId

return items
