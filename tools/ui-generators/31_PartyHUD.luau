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

return function(parent)
	local overlay = C.Frame(parent, "PartyOverlay", UDim2.fromScale(0, 1.04), UDim2.fromScale(1, 2.75))
	overlay.BackgroundTransparency = 1

	local invites = C.New("ScrollingFrame", "InviteQueue", overlay, { Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 0.25), BackgroundTransparency = 1, CanvasSize = UDim2.fromScale(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y })
	C.New("UIListLayout", "UIListLayout", invites, { Padding = UDim.new(0.04, 0), SortOrder = Enum.SortOrder.LayoutOrder })
	local invite = C.New("CanvasGroup", "InviteTemplate", invites, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Paper, Visible = false, LayoutOrder = 0 })
	C.Round(invite, 12)
	C.Stroke(invite, T.Gold).Thickness = 2
	C.New("UIScale", "Pop", invite, { Scale = 1 })
	C.Frame(invite, "Accent", UDim2.fromScale(0, 0), UDim2.fromScale(0.018, 1), T.Gold).ZIndex = 2
	C.Label(invite, "Inviter", "Adventurer invited you to join their party", UDim2.fromScale(0.06, 0.1), UDim2.fromScale(0.88, 0.3), true).TextSize = 15
	local expires = C.Label(invite, "Expires", "Invitation expires soon", UDim2.fromScale(0.06, 0.4), UDim2.fromScale(0.88, 0.16))
	expires.TextColor3 = T.Muted
	expires.TextSize = 11
	C.Button(invite, "Accept", "ACCEPT", UDim2.fromScale(0.06, 0.65), UDim2.fromScale(0.42, 0.27), T.Mint).TextSize = 11
	C.Button(invite, "Decline", "DECLINE", UDim2.fromScale(0.52, 0.65), UDim2.fromScale(0.42, 0.27), T.Soft).TextSize = 11

	local party = C.Frame(overlay, "PartyPanel", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.5), T.Paper)
	C.Round(party, 14)
	C.Stroke(party, T.Gold).Thickness = 2
	local header = C.Frame(party, "Header", UDim2.fromScale(0.04, 0.035), UDim2.fromScale(0.92, 0.12))
	header.BackgroundTransparency = 1
	local title = C.Label(header, "Title", "YOUR PARTY", UDim2.fromScale(0, 0), UDim2.fromScale(0.58, 1), true)
	title.TextColor3 = T.Gold
	title.TextSize = 16
	C.Button(party, "Leave", "LEAVE", UDim2.fromScale(0.72, 0.035), UDim2.fromScale(0.24, 0.12), T.Rose).TextSize = 11

	local members = C.New("ScrollingFrame", "Members", party, { Position = UDim2.fromScale(0.025, 0.18), Size = UDim2.fromScale(0.95, 0.78), BackgroundTransparency = 1, CanvasSize = UDim2.fromScale(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y })
	C.New("UIListLayout", "UIListLayout", members, { Padding = UDim.new(0.04, 0), SortOrder = Enum.SortOrder.LayoutOrder })
	local entry = C.Round(C.Frame(members, "EntryTemplate", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.28), T.Surface), 9)
	entry.Visible = false
	C.Stroke(entry, T.Line).Thickness = 2
	C.Label(entry, "NameLabel", "Adventurer", UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.58, 0.32), true).TextSize = 13
	local leader = C.Label(entry, "Leader", "LEADER", UDim2.fromScale(0.64, 0.08), UDim2.fromScale(0.2, 0.3), true)
	leader.TextColor3 = T.Gold
	leader.TextSize = 9
	C.Button(entry, "Kick", "X", UDim2.fromScale(0.86, 0.1), UDim2.fromScale(0.1, 0.38), T.Rose).TextSize = 14
	local level = C.Label(entry, "Level", "LV. 1", UDim2.fromScale(0.04, 0.52), UDim2.fromScale(0.2, 0.3), true)
	level.TextColor3 = T.Muted
	level.TextSize = 10
	local health = C.Frame(entry, "Health", UDim2.fromScale(0.26, 0.56), UDim2.fromScale(0.68, 0.28))
	health.BackgroundTransparency = 1
	local track = C.Round(C.Frame(health, "Main", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), T.Soft), 6)
	track.ClipsDescendants = true
	C.Round(C.Frame(track, "Bar", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), T.Mint), 6)
	local amount = C.Label(track, "Amount", "-- / --", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), true)
	amount.TextXAlignment = Enum.TextXAlignment.Center
	amount.TextSize = 10
	return overlay
end
end)()
local hud = StarterGui:FindFirstChild("HUD")
assert(hud and hud:IsA("ScreenGui"), "StarterGui.HUD must exist before generating the party HUD.")
local main = hud:FindFirstChild("Main")
assert(main and main:IsA("Frame"), "StarterGui.HUD.Main must exist before generating the party HUD.")

local replacement = build(nil)
local old = main:FindFirstChild("PartyOverlay")
if old then
    local backups = ServerStorage:FindFirstChild("RPGUIBackups")
    if not backups then
        backups = Instance.new("Folder")
        backups.Name = "RPGUIBackups"
        backups.Parent = ServerStorage
    end
    local backup = Instance.new("Folder")
    backup.Name = "PartyOverlay_" .. os.date("%Y-%m-%d_%H-%M-%S")
    backup.Parent = backups
    old.Parent = backup
end
replacement.Parent = main
Selection:Set({ replacement })
print("Party HUD installed below StarterGui.HUD.Main. The prior PartyOverlay is in ServerStorage.RPGUIBackups.")
