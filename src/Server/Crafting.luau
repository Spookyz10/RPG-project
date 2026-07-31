local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Recipes = require(ReplicatedStorage.Shared.Recipes)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local RecipeFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

function UI.Init()
	local Data = UIConstants.Data

	local CraftingFrame = UIConstants.Main:WaitForChild("Crafting")
	local Container = CraftingFrame.Container
	local ItemInfo = CraftingFrame.ItemInfo
	local Template = ReplicatedStorage.Assets.UI.Templates.Recipe

	local SelectedRecipe: string? = nil

	local function BuildRecipeText(itemName: string): string
		local ItemRecipe = Recipes[itemName] :: Types.Recipes
		if not ItemRecipe then
			return ""
		end

		local Parts = {}
		for ingredientName, ingredientInfo in ItemRecipe.Recipe do
			table.insert(Parts, "x" .. ingredientInfo.Amount .. " " .. ingredientName)
		end

		return table.concat(Parts, ", ")
	end

	local function OpenItemInfo(itemName: string)
		local ItemData = ItemsData[itemName] :: Types.Item
		if not ItemData then
			return
		end

		SelectedRecipe = itemName

		ItemInfo.Visible = true
		ItemInfo.Icon.Image = ItemData.Data.Icon
		ItemInfo.ItemName.Text = ItemData.Data.Name

		UIFunctions:ApplyRarityGradient(ItemInfo.Rarity, ItemData.Data.Rarity)

		if ItemData.Kind == "Equipment" then
			ItemInfo.Stats.Visible = true
			UIFunctions:UpdateStatsContainer(ItemInfo.Stats.Info, ItemData.Stats)
		else
			ItemInfo.Stats.Visible = false
		end

		ItemInfo.Recipe.RecipesLabel.Text = BuildRecipeText(itemName)
	end

	local function UpdateRecipeFrame(Frame: ImageButton, itemName: string)
		local ItemData = ItemsData[itemName] :: Types.Item
		if not ItemData then
			return
		end

		Frame.Icon.Image = ItemData.Data.Icon
		UIFunctions:ApplyRarityGradient(Frame.Rarity, ItemData.Data.Rarity)
	end

	local function CreateRecipeFrame(itemName: string)
		if RecipeFrames[itemName] then
			return
		end

		local Frame = Template:Clone()
		Frame.Name = itemName
		Frame.Parent = Container

		UpdateRecipeFrame(Frame, itemName)

		local ClickConnection = Frame.MouseButton1Click:Connect(function()
			OpenItemInfo(itemName)
		end)

		RecipeFrames[itemName] = {
			Frame = Frame,
			Disconnectors = {
				function()
					ClickConnection:Disconnect()
				end,
			},
		}
	end

	local function RemoveRecipeFrame(itemName: string)
		local Entry = RecipeFrames[itemName]
		if not Entry then
			return
		end

		for _, Disconnect in Entry.Disconnectors do
			Disconnect()
		end

		Entry.Frame:Destroy()
		RecipeFrames[itemName] = nil
	end

	local function LoadRecipes(UnlockedRecipes: { string })
		local Seen = {}

		for _, itemName in UnlockedRecipes do
			Seen[itemName] = true
			CreateRecipeFrame(itemName)
		end

		for itemName in RecipeFrames do
			if not Seen[itemName] then
				RemoveRecipeFrame(itemName)
			end
		end
	end

	ItemInfo.Craft.MouseButton1Click:Connect(function()
		if not SelectedRecipe then
			return
		end

		RemoteManager.SendServerEvent("CraftItem", SelectedRecipe)
	end)

	ItemInfo.Visible = false

	LoadRecipes(Data.UnlockedRecipes())

	Data.UnlockedRecipes.Changed(function(NewList)
		LoadRecipes(NewList)
	end)
end

return UI
