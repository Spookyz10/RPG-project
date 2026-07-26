local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server
local RecipeManager = {}

function RecipeManager:AddRecipe(recipe: string, player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Recipes = PlayerData.Recipes()
	if not table.find(Recipes, recipe) then
		PlayerData.Recipes.Insert(recipe)
	end
end

function RecipeManager:HasRecipe(recipe: string, player: Player): boolean
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false
	end

	local Recipes = PlayerData.Recipes()
	if table.find(Recipes, recipe) then
		return true
	end

	return false
end
return RecipeManager
