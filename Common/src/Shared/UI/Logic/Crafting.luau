local RS = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.UIConstants)
local UIFunctions = require(script.Parent.Parent.UIFunctions)
local Recipes = require(RS.Shared.CraftingRecipes)
local Items = require(RS.Shared.ItemsData)
local Functions = require(RS.Shared.Utils.Functions)
local Remote = require(RS.Shared.Utils.RemoteManager)
local Abbreviation = require(RS.Shared.Utils.Abbreviation)
local Theme = require(script.Parent.Parent.Theme)
local Crafting = {}

function Crafting.Init()
	local screen = Constants.PlayerGui:FindFirstChild("Crafting")
	if not screen then
		return
	end
	local Tooltip
	if screen:FindFirstChild("ItemTooltip") then
		Tooltip = require(script.Parent.Parent.ItemTooltip).new()
		Tooltip.Init(screen)
	end
	local data = Constants.Data
	local recipeTemplate = screen:FindFirstChild("RecipeTemplate")
	if not recipeTemplate then
		return
	end
	local usesRecipeCards = recipeTemplate:FindFirstChild("Result") ~= nil
		and recipeTemplate:FindFirstChild("ResultIcon", true) ~= nil
	if not usesRecipeCards then
		warn(
			"Crafting is using the legacy RecipeTemplate. Run tools/ui-generators/35_CraftingRecipeTemplate.luau to enable recipe and material icons."
		)
	end
	local rows = {}
	local ingredientRows = {}
	local keys = {}
	for id in Recipes do
		table.insert(keys, id)
	end
	table.sort(keys, function(a, b)
		return Recipes[a].Level < Recipes[b].Level
	end)
	for index, id in keys do
		local info = Items[id]
		local row = recipeTemplate:Clone()
		row.Name, row.LayoutOrder, row.Visible = id, index, true
		if usesRecipeCards then
			UIFunctions:SetIcon(row.Result.ResultIcon, info.Data.Icon)
			row.Result.ResultName.Text = info.Data.Name
			row.Title.Text = info.Data.Name
			row.Level.Text = "LV. " .. Abbreviation:Number(Recipes[id].Level)
		else
			row.Title.Text = info.Data.Name .. "  |  Lv. " .. Abbreviation:Number(Recipes[id].Level)
		end
		row.Description.Text = info.Data.Description or ""
		if usesRecipeCards then
			ingredientRows[id] = {}
			local ingredients = {}
			for material in Recipes[id].Ingredients do
				table.insert(ingredients, material)
			end
			table.sort(ingredients)
			for ingredientIndex, material in ingredients do
				local materialInfo = Items[material]
				local ingredient = row.IngredientTemplate:Clone()
				ingredient.Name = material
				ingredient.LayoutOrder = ingredientIndex
				ingredient.Visible = true
				UIFunctions:SetIcon(ingredient.Icon, materialInfo and materialInfo.Data.Icon)
				ingredient.ItemName.Text = materialInfo and materialInfo.Data.Name or material
				ingredient.Parent = row.Ingredients
				ingredientRows[id][material] = ingredient
			end
		end
		row.Parent = screen.Main.Body.Content.Container
		if Tooltip then
			Tooltip.Bind(row, function()
				return { ID = info.Data.ID, Name = info.Data.Name, Amount = 1 }
			end)
		end
		rows[id] = row
		local pending = false
		row.Craft.Activated:Connect(function()
			if pending or not row.Craft:GetAttribute("CanCraft") then
				return
			end
			pending = true
			if Tooltip then
				Tooltip.Hide()
			end
			Remote.SendServerEvent("CraftItem", id)
			task.delay(0.5, function()
				pending = false
			end)
		end)
	end
	local function refresh()
		local counts = {}
		for _, entry in data.Inventory() do
			local info = Functions:GetItemInfo(entry)
			if info then
				counts[info.Data.ID] = (counts[info.Data.ID] or 0) + entry.Amount
			end
		end
		for id, row in rows do
			local recipe = Recipes[id]
			local enough = data.Level() >= recipe.Level and (data.Currencies().Gold or 0) >= recipe.Gold
			local costs = usesRecipeCards and nil or { Abbreviation:Number(recipe.Gold) .. " Gold" }
			if usesRecipeCards then
				row.Gold.Text = Abbreviation:Number(recipe.Gold) .. " GOLD"
			end
			for material, amount in recipe.Ingredients do
				local owned = counts[material] or 0
				if usesRecipeCards then
					local ingredient = ingredientRows[id][material]
					ingredient.Count.Text = Abbreviation:Number(owned) .. " / " .. Abbreviation:Number(amount)
					ingredient.Count.TextColor3 = owned >= amount and Theme.Mint or Theme.Red
				else
					table.insert(
						costs,
						material .. " " .. Abbreviation:Number(owned) .. "/" .. Abbreviation:Number(amount)
					)
				end
				if owned < amount then
					enough = false
				end
			end
			if costs then
				table.sort(costs)
				row.Gold.Text = table.concat(costs, "  |  ")
			end
			row.Craft.Text = enough and "CRAFT" or "Requirements not met"
			row.Craft:SetAttribute("CanCraft", enough)
		end
	end
	data.Inventory.Changed(refresh)
	data.Currencies.Changed(refresh)
	data.Level.Changed(refresh)
	refresh()
end
return Crafting
