local RS = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.UIConstants)
local Recipes = require(RS.Shared.CraftingRecipes)
local Items = require(RS.Shared.ItemsData)
local Functions = require(RS.Shared.Utils.Functions)
local Remote = require(RS.Shared.Utils.RemoteManager)
local Crafting = {}

function Crafting.Init()
	local screen = Constants.PlayerGui:FindFirstChild("Crafting")
	if not screen then return end
	local data = Constants.Data
	local rows = {}
	local keys = {}
	for id in Recipes do table.insert(keys, id) end
	table.sort(keys, function(a,b) return Recipes[a].Level < Recipes[b].Level end)
	for index, id in keys do
		local info = Items[id]
		local row = screen.RecipeTemplate:Clone()
		row.Name, row.LayoutOrder, row.Visible = id, index, true
		row.Title.Text = info.Data.Name .. "  |  Lv. " .. Recipes[id].Level
		row.Description.Text = info.Data.Description or ""
		row.Parent = screen.Main.Body.Content.Container
		rows[id] = row
		local pending = false
		row.Craft.Activated:Connect(function()
			if pending or not row.Craft:GetAttribute("CanCraft") then return end
			pending = true
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
			local costs = { tostring(recipe.Gold) .. " Gold" }
			for material, amount in recipe.Ingredients do
				local owned = counts[material] or 0
				table.insert(costs, material .. " " .. owned .. "/" .. amount)
				if owned < amount then enough = false end
			end
			table.sort(costs)
			row.Cost.Text = table.concat(costs, "  |  ")
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
