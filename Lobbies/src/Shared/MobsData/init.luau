local mobs = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		mobs[module.Name] = require(module)
	end
end

return mobs
