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

local function ensureNotification(button: GuiButton)
	local existing = button:FindFirstChild("Notification")
	if existing then return existing end
	local badge = C.Round(C.Label(button, "Notification", "1", UDim2.fromScale(0.76, -0.16), UDim2.fromScale(0.32, 0.48), true), 10)
	badge.BackgroundTransparency = 0
	badge.BackgroundColor3 = T.Rose
	badge.TextXAlignment = Enum.TextXAlignment.Center
	badge.TextSize = 11
	badge.Visible = false
	badge.ZIndex = button.ZIndex + 3
	C.Stroke(badge, T.Ink).Thickness = 2
	return badge
end

return function()
	local screen = StarterGui:FindFirstChild("Buttons")
	assert(screen and screen:IsA("ScreenGui"), "StarterGui.Buttons must exist before installing Journal indicators.")
	local main = screen:FindFirstChild("Main")
	assert(main and main:IsA("GuiObject"), "StarterGui.Buttons.Main must exist before installing Journal indicators.")
	local menu = main:FindFirstChild("Menu")
	local backpack = main:FindFirstChild("Backpack")
	assert(menu and menu:IsA("GuiButton"), "StarterGui.Buttons.Main.Menu must exist.")
	assert(backpack and backpack:IsA("GuiButton"), "StarterGui.Buttons.Main.Backpack must exist.")

	local journal = main:FindFirstChild("Journal")
	if journal then
		assert(journal:IsA("GuiButton"), "StarterGui.Buttons.Main.Journal must be a GuiButton.")
	else
		journal = C.Button(main, "Journal", "Quests", UDim2.fromScale(0, 0.4), backpack.Size, T.Sky)
	end
	journal:SetAttribute("OpenScreen", "Journal")

	local drawer = main:FindFirstChild("Drawer")
	local items = drawer and drawer:FindFirstChild("Items")
	local drawerJournal = items and items:FindFirstChild("Journal")
	if items and not drawerJournal then
		drawerJournal = C.Button(items, "Journal", "Quest journal", UDim2.new(), UDim2.fromScale(1, 0.12), T.Sky)
		drawerJournal.LayoutOrder = 5
		drawerJournal:SetAttribute("OpenScreen", "Journal")
	end
	if drawerJournal and drawerJournal:IsA("GuiButton") then
		drawerJournal.Visible = true
		ensureNotification(drawerJournal)
	end

	ensureNotification(menu)
	ensureNotification(journal)
	Selection:Set({ menu, journal })
	print("Journal shortcut and quest notification badges installed without replacing StarterGui.Buttons.")
end
end)()
local recording
pcall(function() recording = History:TryBeginRecording("ApplyRPGUIPatch", "Apply RPG UI patch") end)
local ok, reason = pcall(build)
if recording then
    History:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
if not ok then error("UI patch failed: " .. tostring(reason)) end
