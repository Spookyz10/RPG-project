local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Recipes = require(ReplicatedStorage.Shared.Recipes)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local ItemDisplay = require(ReplicatedStorage.Shared.UI.ItemDisplay)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local RecipeFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

function UI.Init()
	local Data = UIConstants.Data

	local CraftingFrame = UIConstants.Main:WaitForChild("Crafting")
	local Container = CraftingFrame.Recipes.Container
	local ItemInfo = CraftingFrame.InfoFrame
	local MainInfo = ItemInfo.MainInfo

	local RecipeButton = MainInfo.RecipeButton
	local StatsButton = MainInfo.StatsButton
	local RecipeContentFrame = MainInfo.Recipe
	local StatsContentFrame = MainInfo.Stats

	local Template = ReplicatedStorage.Assets.UI.Templates.Recipe
	local RecipeLabelTemplate = ReplicatedStorage.Assets.UI.Templates.RecipeLabel

	local SelectedRecipe: string? = nil
	local IngredientDisconnect: (() -> ())? = nil

	local function ShowTab(tabName: string)
		RecipeContentFrame.Visible = tabName == "Recipe"
		StatsContentFrame.Visible = tabName == "Stats"
	end

	local function GetInventoryCounts(): { [string]: number }
		local Counts = {}
		for _, itemData in Data.Inventory() do
			Counts[itemData.Name] = (Counts[itemData.Name] or 0) + itemData.Amount
		end
		return Counts
	end

	local function RenderRecipe(itemName: string)
		for _, child in RecipeContentFrame:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local ItemRecipe = Recipes[itemName] :: Types.Recipes
		if not ItemRecipe then
			return
		end

		local Counts = GetInventoryCounts()

		for ingredientName, ingredientInfo in ItemRecipe.Recipe do
			local Label = RecipeLabelTemplate:Clone()
			local Current = Counts[ingredientName] or 0
			Label.Text = ingredientInfo.Amount
				.. " "
				.. ingredientName
				.. " ("
				.. Current
				.. "/"
				.. ingredientInfo.Amount
				.. ")"
			Label.Parent = RecipeContentFrame
		end
	end

	local function OpenItemInfo(itemName: string)
		local ItemData = ItemsData[itemName] :: Types.Item
		if not ItemData then
			return
		end

		SelectedRecipe = itemName

		ItemInfo.Visible = true
		ItemInfo.ImageContainer.Icon.Image = ItemData.Data.Icon
		ItemInfo.ItemName.Text = ItemData.Data.Name
		ItemInfo.Level.Text = "Level: " .. ItemData.Data.Level
		ItemInfo.Rarity.Text = ItemData.Data.Rarity
		ItemInfo.Description.Text = ItemData.Data.Description

		UIFunctions:ApplyRarityGradient(ItemInfo.ImageContainer.Rarity, ItemData.Data.Rarity)

		if ItemData.Kind == "Equipment" then
			StatsContentFrame.Visible = true
			UIFunctions:UpdateStatsContainer(StatsContentFrame.Info, ItemData.Stats)
		else
			StatsContentFrame.Visible = false
		end

		ShowTab("Recipe")
		RenderRecipe(itemName)

		if IngredientDisconnect then
			IngredientDisconnect()
			IngredientDisconnect = nil
		end

		IngredientDisconnect = Data.Inventory.Changed(function()
			if SelectedRecipe == itemName then
				RenderRecipe(itemName)
			end
		end)
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

		local HoverConnection = Frame.MouseEnter:Connect(function()
			ItemDisplay:Hover(Frame, { Name = itemName })
		end)

		RecipeFrames[itemName] = {
			Frame = Frame,
			Disconnectors = {
				function()
					ClickConnection:Disconnect()
				end,
				function()
					HoverConnection:Disconnect()
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

	RecipeButton.MouseButton1Click:Connect(function()
		ShowTab("Recipe")
	end)

	StatsButton.MouseButton1Click:Connect(function()
		ShowTab("Stats")
	end)

	ItemInfo.Action.MouseButton1Click:Connect(function()
		if not SelectedRecipe then
			return
		end

		RemoteManager.SendServerEvent("CraftItem", SelectedRecipe)
	end)

	ItemInfo.Visible = false
	ShowTab("Recipe")

	LoadRecipes(Data.UnlockedRecipes())

	print(Data.UnlockedRecipes())

	Data.UnlockedRecipes.Changed(function(NewList)
		LoadRecipes(NewList)
	end)
end

return UI
