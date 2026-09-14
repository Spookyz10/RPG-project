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

return function()
	local templates = game:GetService("ReplicatedStorage"):FindFirstChild("RPGUITemplates")
	assert(templates, "Generate RPGUITemplates before upgrading the shop template.")
	local card = templates:FindFirstChild("ShopTemplate")
	assert(card and card:IsA("GuiObject"), "RPGUITemplates.ShopTemplate must be a GuiObject.")
	card.Size = UDim2.new(1, -8, 0, 206)
	local oldBuy = card:FindFirstChild("Buy")
	assert(oldBuy and oldBuy:IsA("TextButton"), "ShopTemplate.Buy must be a TextButton.")
	oldBuy.Position = UDim2.fromScale(0.06, 0.82)
	oldBuy.Size = UDim2.fromScale(0.88, 0.15)
	local oldQuantity = card:FindFirstChild("Quantity")
	if oldQuantity then oldQuantity:Destroy() end
	local oldTotal = card:FindFirstChild("Total")
	if oldTotal then oldTotal:Destroy() end
	local quantity = C.Round(C.Frame(card, "Quantity", UDim2.fromScale(0.06, 0.47), UDim2.fromScale(0.88, 0.2), T.Soft), 8)
	C.Stroke(quantity)
	C.Button(quantity, "Minus", "-", UDim2.fromScale(0.02, 0.12), UDim2.fromScale(0.2, 0.76), T.Rose)
	local amount = C.Label(quantity, "Amount", "1", UDim2.fromScale(0.26, 0.12), UDim2.fromScale(0.48, 0.76), true)
	amount.TextXAlignment = Enum.TextXAlignment.Center
	C.Button(quantity, "Plus", "+", UDim2.fromScale(0.78, 0.12), UDim2.fromScale(0.2, 0.76), T.Mint)
	C.Label(card, "Total", "Total: 0 Gold", UDim2.fromScale(0.07, 0.7), UDim2.fromScale(0.86, 0.1)).TextColor3 = T.Muted
end
end)()
local recording
pcall(function() recording = History:TryBeginRecording("ApplyRPGUIPatch", "Apply RPG UI patch") end)
local ok, reason = pcall(build)
if recording then
    History:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
if not ok then error("UI patch failed: " .. tostring(reason)) end
