local Recipes = {}

for _, recipe in script:GetDescendants() do
	if recipe:IsA("ModuleScript") then
		Recipes[recipe.Name] = require(recipe)
	end
end

return Recipes
