local shops = {}

for _, shop in script:GetDescendants() do
	if shop:IsA("ModuleScript") then
		shops[shop.Name] = require(shop)
	end
end
