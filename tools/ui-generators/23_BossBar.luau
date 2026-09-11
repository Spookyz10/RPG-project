-- Standalone Studio Command Bar / Edit mode generator.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local function make(class, name, parent, props)
	local obj = Instance.new(class); obj.Name = name
	for key, value in props or {} do obj[key] = value end
	obj.Parent = parent; return obj
end
local function label(name, parent, position, size, text)
	return make("TextLabel", name, parent, {Position = position, Size = size, BackgroundTransparency = 1,
		Text = text, Font = Enum.Font.GothamBold, TextScaled = true, TextColor3 = Color3.fromRGB(255, 238, 209), ZIndex = 3})
end
local gui = make("ScreenGui", "BossBar", nil, {ResetOnSpawn = false, IgnoreGuiInset = false, DisplayOrder = 15})
local main = make("Frame", "Main", gui, {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.025), Size = UDim2.fromScale(0.58, 0.1), BackgroundColor3 = Color3.fromRGB(28, 25, 24), BorderSizePixel = 0, Visible = false})
make("UISizeConstraint", "Bounds", main, {MaxSize = Vector2.new(760, 110), MinSize = Vector2.new(240, 64)})
make("UICorner", "Corner", main, {CornerRadius = UDim.new(0.15, 0)})
make("UIStroke", "Border", main, {Color = Color3.fromRGB(183, 139, 69), Thickness = 2})
label("Title", main, UDim2.fromScale(0.04, 0.06), UDim2.fromScale(0.92, 0.32), "Dire Bear  •  Lv. 15")
local track = make("Frame", "Track", main, {Position = UDim2.fromScale(0.04, 0.47), Size = UDim2.fromScale(0.92, 0.39), BackgroundColor3 = Color3.fromRGB(53, 28, 27), BorderSizePixel = 0, ClipsDescendants = true})
local fill = make("Frame", "Fill", track, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(185, 58, 44), BorderSizePixel = 0})
make("UIGradient", "Gradient", fill, {Color = ColorSequence.new(Color3.fromRGB(239, 106, 59), Color3.fromRGB(148, 36, 39)), Rotation = 90})
label("Health", main, UDim2.fromScale(0.04, 0.49), UDim2.fromScale(0.92, 0.33), "2400 / 2400")
local timer = make("BillboardGui", "BossRespawn", nil, {Size = UDim2.fromScale(16, 4), AlwaysOnTop = true, MaxDistance = 180, LightInfluence = 0})
local text = label("Countdown", timer, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), "Dire Bear\nRespawns in 30s")
text.TextStrokeTransparency = 0.2
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local templates = RS:FindFirstChild("RPGUITemplates") or make("Folder", "RPGUITemplates", RS)
local backups = SS:FindFirstChild("RPGUIBackups") or make("Folder", "RPGUIBackups", SS)
local backup = make("Folder", "BossBar_" .. os.date("%Y%m%d_%H%M%S"), backups)
for _, entry in {{gui, game:GetService("StarterGui")}, {timer, templates}} do
	local old = entry[2]:FindFirstChild(entry[1].Name)
	if old then old.Parent = backup end
	entry[1].Parent = entry[2]
end
game:GetService("Selection"):Set({main})
print("BossBar and BossRespawn saved. Toggle Main.Visible to preview; save before Play.")
