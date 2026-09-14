-- Run in Edit. Move the two selected models above your portals afterward.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating portal signs.")
local SS = game:GetService("ServerStorage")
local History = game:GetService("ChangeHistoryService")
local function folder(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then assert(existing:IsA("Folder"), name .. " must be a Folder"); return existing end
	local f = Instance.new("Folder"); f.Name = name; f.Parent = parent; return f
end
local function new(class, name, parent, props)
	local o = Instance.new(class); o.Name = name
	if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
	for key, value in props do o[key] = value end
	o.Parent = parent; return o
end
local function round(o, radius)
	new("UICorner", "Corner", o, {CornerRadius = UDim.new(radius or 0.12, 0)})
end
local function label(parent, name, text, position, size, color, font)
	return new("TextLabel", name, parent, {
		Position = position, Size = size, BackgroundTransparency = 1, Text = text,
		TextColor3 = color, TextScaled = true, TextWrapped = true, Font = font or Enum.Font.FredokaOne,
		TextStrokeColor3 = Color3.fromRGB(10, 12, 19), TextStrokeTransparency = 0.2,
	})
end
local target = workspace:FindFirstChild("PortalSigns")
assert(not target or target:IsA("Folder"), "Workspace.PortalSigns must be a Folder")
local staging = Instance.new("Folder")
local selected = {}
for i, def in {
	{"Zones", "ZONES", "EXPLORE NEW WORLDS", Color3.fromRGB(76, 184, 255), Color3.fromRGB(28, 82, 146)},
	{"Raids", "RAIDS", "ASSEMBLE YOUR PARTY", Color3.fromRGB(255, 111, 118), Color3.fromRGB(146, 36, 62)},
} do
	local model = new("Model", def[1], staging, {})
	local anchor = new("Part", "Anchor", model, {
		Size = Vector3.one, CFrame = CFrame.new((i - 1) * 22, 14, 0), Transparency = 1,
		Anchored = true, CanCollide = false, CanTouch = false,
	})
	model.PrimaryPart = anchor
	local board = new("BillboardGui", "PortalBillboard", anchor, {
		Size = UDim2.fromScale(18, 5.2), AlwaysOnTop = false, LightInfluence = 0,
		MaxDistance = 180, ResetOnSpawn = false,
	})
	local main = new("Frame", "Main", board, {
		Position = UDim2.fromScale(0.025, 0.06), Size = UDim2.fromScale(0.95, 0.86),
		BackgroundColor3 = Color3.fromRGB(28, 31, 44),
	})
	round(main)
	new("UIStroke", "Outline", main, {Color = def[4], Thickness = 3})
	new("UIGradient", "Shade", main, {Color = ColorSequence.new(def[5], Color3.fromRGB(36, 39, 56)), Rotation = 15})
	local emblem = new("Frame", "Emblem", main, {
		Position = UDim2.fromScale(0.045, 0.16), Size = UDim2.fromScale(0.16, 0.65), BackgroundColor3 = def[5],
	})
	round(emblem, 0.25)
	new("UIStroke", "Outline", emblem, {Color = def[4], Thickness = 2})
	label(emblem, "Symbol", i == 1 and ">>" or "!", UDim2.fromScale(0.05, 0.12), UDim2.fromScale(0.9, 0.76), def[4])
	label(main, "Title", def[2], UDim2.fromScale(0.22, 0.09), UDim2.fromScale(0.69, 0.5), def[4])
	label(main, "Subtitle", def[3], UDim2.fromScale(0.22, 0.62), UDim2.fromScale(0.69, 0.17), Color3.fromRGB(235, 240, 255), Enum.Font.GothamBold)
	local accent = new("Frame", "Accent", main, {
		Position = UDim2.fromScale(0.27, 0.86), Size = UDim2.fromScale(0.59, 0.025), BackgroundColor3 = def[4],
	})
	round(accent)
	local old = target and target:FindFirstChild(def[1])
	if old and old:IsA("Model") then model:PivotTo(old:GetPivot()) end
	table.insert(selected, model)
end
local recording
pcall(function() recording = History:TryBeginRecording("GeneratePortalSigns", "Generate portal billboards") end)
target = target or folder(workspace, "PortalSigns")
for _, model in selected do
	local old = target:FindFirstChild(model.Name)
	if old then
		local backup = Instance.new("Folder")
		backup.Name = model.Name .. "_" .. os.date("%Y%m%d_%H%M%S")
		backup.Parent = folder(SS, "WorldGeneratorBackups")
		old.Parent = backup
	end
	model.Parent = target
end
staging:Destroy()
game:GetService("Selection"):Set(selected)
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Zones and Raids signs generated in Workspace.PortalSigns. Move each model above its portal; no triggers were created.")
