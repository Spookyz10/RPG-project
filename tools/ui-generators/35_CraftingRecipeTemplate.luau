assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")
local T = (function()
local Theme = {
	Paper = Color3.fromRGB(32, 33, 41),
	Surface = Color3.fromRGB(44, 46, 57),
	Soft = Color3.fromRGB(61, 63, 76),
	Ink = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(191, 197, 215),
	Line = Color3.fromRGB(10, 12, 19),
	Green = Color3.fromRGB(67, 222, 112),
	Mint = Color3.fromRGB(38, 184, 84),
	Blue = Color3.fromRGB(76, 184, 255),
	Sky = Color3.fromRGB(35, 138, 228),
	Gold = Color3.fromRGB(255, 208, 81),
	Sand = Color3.fromRGB(225, 153, 32),
	Red = Color3.fromRGB(255, 111, 118),
	Rose = Color3.fromRGB(221, 65, 82),
	Purple = Color3.fromRGB(153, 89, 234),
	Highlight = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	Bold = Enum.Font.FredokaOne,
	CornerRadius = 8,
	StrokeThickness = 3,
}
Theme.Rarities = {
	Common = Color3.fromRGB(111, 124, 145),
	Uncommon = Theme.Mint,
	Rare = Theme.Sky,
	Legendary = Color3.fromRGB(217, 64, 156),
	Godly = Theme.Sand,
	Ascendant = Theme.Purple,
}
return Theme
end)()
local C = (function()
local C = {}

function C.New(className, name, parent, properties)
	local object = Instance.new(className)
	object.Name = name
	if object:IsA("GuiObject") then object.BorderSizePixel = 0 end
	if object:IsA("TextLabel") or object:IsA("TextButton") then
		object.Font = T.Font
		object.TextScaled = true
		object.TextColor3 = T.Ink
		object.TextWrapped = true
		object.TextStrokeColor3 = T.Line
		object.TextStrokeTransparency = 0.15
	end
	for key, value in properties or {} do object[key] = value end
	object.Parent = parent
	return object
end

function C.Round(object, radius)
	C.New("UICorner", "UICorner", object, { CornerRadius = UDim.new(0.12, 0) })
	return object
end

function C.Stroke(object, color)
	return C.New("UIStroke", "UIStroke", object, { Color = color or T.Line, Thickness = T.StrokeThickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

function C.Frame(parent, name, position, size, color)
	return C.New("Frame", name, parent, { Position = position, Size = size, BackgroundTransparency = color and 0 or 1, BackgroundColor3 = color or T.Surface })
end

function C.Label(parent, name, text, position, size, bold)
	return C.New("TextLabel", name, parent, { Text = text, Position = position, Size = size, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = bold and T.Bold or T.Font })
end

function C.Button(parent, name, text, position, size, color)
	local button = C.New("TextButton", name, parent, { Text = text, Position = position, Size = size, BackgroundColor3 = color or T.Mint, AutoButtonColor = true })
	C.Round(button, 10)
	C.Stroke(button)
	button.Font = T.Bold
	button:SetAttribute("HoverButton", true)
	return button
end

return C
end)()
local build = (function()

local function recipeTemplate()
	local row = C.Round(C.Frame(nil, "RecipeTemplate", UDim2.fromScale(0, 0), UDim2.fromScale(0.985, 0.36), T.Paper), 12)
	row.Visible = false
	C.Stroke(row, T.Line).Thickness = 2

	local result = C.Round(C.Frame(row, "Result", UDim2.fromScale(0.025, 0.09), UDim2.fromScale(0.19, 0.82), T.Surface), 10)
	C.Stroke(result, T.Soft).Thickness = 2
	local resultLabel = C.Label(result, "Label", "RESULT", UDim2.fromScale(0.08, 0.05), UDim2.fromScale(0.84, 0.14), true)
	resultLabel.TextColor3 = T.Gold
	resultLabel.TextXAlignment = Enum.TextXAlignment.Center
	C.New("ImageLabel", "ResultIcon", result, {
		Position = UDim2.fromScale(0.14, 0.23),
		Size = UDim2.fromScale(0.72, 0.58),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
	})
	local resultName = C.Label(result, "ResultName", "Item", UDim2.fromScale(0.08, 0.82), UDim2.fromScale(0.84, 0.12), true)
	resultName.TextXAlignment = Enum.TextXAlignment.Center

	local title = C.Label(row, "Title", "Recipe", UDim2.fromScale(0.24, 0.08), UDim2.fromScale(0.5, 0.14), true)
	title.TextColor3 = T.Ink
	local level = C.Round(C.Label(row, "Level", "LV. 1", UDim2.fromScale(0.75, 0.08), UDim2.fromScale(0.2, 0.14), true), 8)
	level.BackgroundColor3 = T.Soft
	level.BackgroundTransparency = 0
	level.TextColor3 = T.Gold
	level.TextXAlignment = Enum.TextXAlignment.Center
	local description = C.Label(row, "Description", "", UDim2.fromScale(0.24, 0.24), UDim2.fromScale(0.71, 0.22))
	description.TextColor3 = T.Muted
	description.TextYAlignment = Enum.TextYAlignment.Top

	local materialsLabel = C.Label(row, "MaterialsLabel", "MATERIALS", UDim2.fromScale(0.24, 0.48), UDim2.fromScale(0.36, 0.09), true)
	materialsLabel.TextColor3 = T.Muted
	local ingredients = C.New("Frame", "Ingredients", row, {
		Position = UDim2.fromScale(0.24, 0.58),
		Size = UDim2.fromScale(0.71, 0.18),
		BackgroundTransparency = 1,
	})
	C.New("UIGridLayout", "Layout", ingredients, {
		CellSize = UDim2.fromScale(0.32, 1),
		CellPadding = UDim2.fromScale(0.02, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local ingredient = C.Round(C.Frame(row, "IngredientTemplate", UDim2.fromScale(0, 0), UDim2.fromScale(0.32, 1), T.Surface), 8)
	ingredient.Visible = false
	C.Stroke(ingredient, T.Soft).Thickness = 1
	C.New("ImageLabel", "Icon", ingredient, {
		Position = UDim2.fromScale(0.05, 0.16),
		Size = UDim2.fromScale(0.24, 0.68),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
	})
	local ingredientName = C.Label(ingredient, "ItemName", "Material", UDim2.fromScale(0.34, 0.12), UDim2.fromScale(0.6, 0.42), true)
	ingredientName.TextTruncate = Enum.TextTruncate.AtEnd
	local count = C.Label(ingredient, "Count", "0 / 0", UDim2.fromScale(0.34, 0.55), UDim2.fromScale(0.6, 0.3), true)
	count.TextColor3 = T.Muted

	local gold = C.Label(row, "Gold", "0 GOLD", UDim2.fromScale(0.24, 0.84), UDim2.fromScale(0.38, 0.1), true)
	gold.TextColor3 = T.Gold
	local craft = C.Button(row, "Craft", "CRAFT", UDim2.fromScale(0.68, 0.81), UDim2.fromScale(0.27, 0.13), T.Mint)
	craft.TextXAlignment = Enum.TextXAlignment.Center
	return row
end

return function()
	local crafting = StarterGui:FindFirstChild("Crafting")
	assert(crafting and crafting:IsA("ScreenGui"), "StarterGui.Crafting must exist before replacing its recipe template.")
	local old = crafting:FindFirstChild("RecipeTemplate")
	assert(old and old:IsA("GuiObject"), "StarterGui.Crafting.RecipeTemplate must exist.")

	local replacement = recipeTemplate()
	local backups = ServerStorage:FindFirstChild("RPGUIBackups")
	if not backups then
		backups = Instance.new("Folder")
		backups.Name = "RPGUIBackups"
		backups.Parent = ServerStorage
	end
	local backup = Instance.new("Folder")
	backup.Name = "CraftingRecipeTemplate_" .. os.date("%Y-%m-%d_%H-%M-%S")
	backup.Parent = backups
	old.Parent = backup
	replacement.Parent = crafting
	Selection:Set({ replacement })
	print("Crafting RecipeTemplate upgraded. The rest of StarterGui.Crafting was not changed.")
end
end)()
local recording
pcall(function() recording = History:TryBeginRecording("ApplyRPGUIPatch", "Apply RPG UI patch") end)
local ok, reason = pcall(build)
if recording then
    History:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
if not ok then error("UI patch failed: " .. tostring(reason)) end
