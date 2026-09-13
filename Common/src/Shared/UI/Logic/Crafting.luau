local RS = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.UIConstants)
local Recipes = require(RS.Shared.CraftingRecipes)
local Items = require(RS.Shared.ItemsData)
local Functions = require(RS.Shared.Utils.Functions)
local Remote = require(RS.Shared.Utils.RemoteManager)
local Abbreviation = require(RS.Shared.Utils.Abbreviation)
local Theme = require(script.Parent.Parent.Theme)
local Crafting = {}

function Crafting.Init()
	local screen = Constants.PlayerGui:FindFirstChild("Crafting")
	if not screen then return end
	local Tooltip
	if screen:FindFirstChild("ItemTooltip") then
		Tooltip = require(script.Parent.Parent.ItemTooltip).new()
		Tooltip.Init(screen)
	end
	local data = Constants.Data
	local rows = {}
	local ingredientRows = {}
	local keys = {}
	for id in Recipes do table.insert(keys, id) end
	table.sort(keys, function(a,b) return Recipes[a].Level < Recipes[b].Level end)
	for index, id in keys do
		local info = Items[id]
		local row = screen.RecipeTemplate:Clone()
		row.Name, row.LayoutOrder, row.Visible = id, index, true
		row.ResultIcon.Image = info.Data.Icon or ""
		row.ResultName.Text = info.Data.Name
		row.Title.Text = info.Data.Name
		row.Level.Text = "LV. " .. Abbreviation:Number(Recipes[id].Level)
		row.Description.Text = info.Data.Description or ""
		ingredientRows[id] = {}
		local ingredients = {}
		for material in Recipes[id].Ingredients do table.insert(ingredients, material) end
		table.sort(ingredients)
		for ingredientIndex, material in ingredients do
			local materialInfo = Items[material]
			local ingredient = row.IngredientTemplate:Clone()
			ingredient.Name = material
			ingredient.LayoutOrder = ingredientIndex
			ingredient.Visible = true
			ingredient.Icon.Image = materialInfo and materialInfo.Data.Icon or ""
			ingredient.ItemName.Text = materialInfo and materialInfo.Data.Name or material
			ingredient.Parent = row.Ingredients
			ingredientRows[id][material] = ingredient
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
			if pending or not row.Craft:GetAttribute("CanCraft") then return end
			pending = true
			if Tooltip then Tooltip.Hide() end
			Remote.SendServerEvent("CraftItem", id)
			task.delay(0.5, function() pending = false end)
		end)
	end
	local function refresh()
		local counts = {}
		for _, entry in data.Inventory() do
			local info = Functions:GetItemInfo(entry)
			if info then counts[info.Data.ID] = (counts[info.Data.ID] or 0) + entry.Amount end
		end
		for id, row in rows do
			local recipe = Recipes[id]
			local enough = data.Level() >= recipe.Level and (data.Currencies().Gold or 0) >= recipe.Gold
			row.Gold.Text = Abbreviation:Number(recipe.Gold) .. " GOLD"
			for material, amount in recipe.Ingredients do
				local owned = counts[material] or 0
				local ingredient = ingredientRows[id][material]
				ingredient.Count.Text = Abbreviation:Number(owned) .. " / " .. Abbreviation:Number(amount)
				ingredient.Count.TextColor3 = owned >= amount and Theme.Mint or Theme.Red
				if owned < amount then enough = false end
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
