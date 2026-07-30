local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local RecipeManager = require(script.Parent.RecipeManager)
local Recipes = require(ReplicatedStorage.Shared.Recipes)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local InventoryManager = require(script.Parent.InventoryManager)
local QuestManager = require(script.Parent.QuestManager)

local CraftingService = {}

function CraftingService:HasRequiredItems(PlayerData: Types.PlayerData, ItemRecipe: Types.Recipes): boolean
	local Inventory = PlayerData.Inventory()
	local ItemCounts = {}

	for _, itemData in Inventory do
		ItemCounts[itemData.Name] = (ItemCounts[itemData.Name] or 0) + itemData.Amount
	end

	for itemName, recipeInfo in ItemRecipe.Recipe do
		if (ItemCounts[itemName] or 0) < recipeInfo.Amount then
			return false
		end
	end

	return true
end

function CraftingService:CraftItem(item: string, player: Player): string
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return "Invalid player data, if you get this then report as a bug."
	end

	local ItemRecipe = Recipes[item] :: Types.Recipes
	if not ItemRecipe then
		return "Recipe not found"
	end

	if not RecipeManager:HasRecipe(item, player) then
		return "Recipe not unlocked"
	end

	local canCraft: boolean, reason: string = ItemRecipe.GetRequirement(PlayerData)

	if not canCraft then
		return reason
	end

	if not CraftingService:HasRequiredItems(PlayerData, ItemRecipe) then
		return "Missing required items"
	end

	for itemName, recipeInfo in ItemRecipe.Recipe do
		local RemoveResult = InventoryManager:RemoveItem(player, itemName, recipeInfo.Amount)
		if RemoveResult ~= "Successfully deleted item" then
			return "Failed to remove: " .. itemName
		end
	end

	InventoryManager:AddItem(player, item, 1)
	QuestManager:OnItemCrafted(player, item)

	return "Succesfully crafted item"
end

return CraftingService
