-- STUDIO COMMAND BAR / EDIT MODE ONLY.
-- Standalone: paste this entire file; no plugin or generator module is required.
-- Existing UI is moved into ServerStorage.RPGUIBackups before replacement.
-- Runtime scripts bind the saved UI and never regenerate it.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")
local build = (function()
-- All UI dimensions use Scale. Billboard scale is measured in world studs.
return function(parent)
	local function create(class, name, owner, properties)
		local object = Instance.new(class)
		object.Name = name
		for key, value in properties do object[key] = value end
		object.Parent = owner
		return object
	end
	local function round(owner, radius)
		create("UICorner", "Corner", owner, { CornerRadius = UDim.new(radius, 0) })
	end
	local function gradient(owner, top, bottom)
		create("UIGradient", "Gradient", owner, { Rotation = 90, Color = ColorSequence.new(top, bottom) })
	end
	local function label(owner, name, text, position, size, color)
		return create("TextLabel", name, owner, {
			Position = position, Size = size, BackgroundTransparency = 1,
			Text = text, TextScaled = true, TextColor3 = color,
			Font = Enum.Font.GothamBold, TextStrokeTransparency = 0.65,
			TextStrokeColor3 = Color3.fromRGB(20, 39, 34), ZIndex = 3,
		})
	end
	local gui = create("BillboardGui", "MobOverhead", parent, {
		Size = UDim2.fromScale(5.4, 1.45), StudsOffsetWorldSpace = Vector3.new(0, 4, 0),
		AlwaysOnTop = true, MaxDistance = 85, LightInfluence = 0,
	})
	local info = create("Frame", "Info", gui, {
		Position = UDim2.fromScale(0.02, 0), Size = UDim2.fromScale(0.96, 0.44), BackgroundTransparency = 1,
	})
	local name = label(info, "MobName", "Bushling", UDim2.fromScale(0, 0.06), UDim2.fromScale(0.73, 0.88), Color3.fromRGB(255, 248, 227))
	name.TextXAlignment = Enum.TextXAlignment.Left
	local badge = create("Frame", "LevelBadge", info, {
		Position = UDim2.fromScale(0.77, 0.1), Size = UDim2.fromScale(0.23, 0.8),
		BackgroundColor3 = Color3.fromRGB(37, 65, 54), BorderSizePixel = 0,
	})
	round(badge, 0.28)
	gradient(badge, Color3.fromRGB(106, 139, 103), Color3.fromRGB(49, 79, 62))
	label(badge, "Level", "Lv. 1", UDim2.fromScale(0.06, 0.1), UDim2.fromScale(0.88, 0.8), Color3.fromRGB(255, 235, 181))
	local hp = create("Frame", "HP", gui, {
		Position = UDim2.fromScale(0, 0.51), Size = UDim2.fromScale(1, 0.47),
		BackgroundColor3 = Color3.fromRGB(22, 40, 34), BorderSizePixel = 0,
	})
	round(hp, 0.3)
	local track = create("Frame", "Track", hp, {
		Position = UDim2.fromScale(0.015, 0.12), Size = UDim2.fromScale(0.97, 0.76),
		BackgroundColor3 = Color3.fromRGB(67, 86, 68), BorderSizePixel = 0, ClipsDescendants = true,
	})
	round(track, 0.25)
	gradient(track, Color3.fromRGB(73, 91, 69), Color3.fromRGB(34, 54, 45))
	local bar = create("Frame", "Bar", track, {
		Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
	})
	round(bar, 0.25)
	gradient(bar, Color3.fromRGB(177, 241, 176), Color3.fromRGB(67, 165, 119))
	label(hp, "Health", "HP  45 / 45", UDim2.fromScale(0.04, 0.17), UDim2.fromScale(0.92, 0.66), Color3.fromRGB(255, 255, 240))
	return gui
end
end)()
local templates = ReplicatedStorage:FindFirstChild("RPGUITemplates")
if not templates then templates = Instance.new("Folder"); templates.Name = "RPGUITemplates"; templates.Parent = ReplicatedStorage end
local replacement = build(nil)
local old = templates:FindFirstChild("MobOverhead")
if old then
 local backups = ServerStorage:FindFirstChild("RPGUIBackups")
 if not backups then backups = Instance.new("Folder"); backups.Name = "RPGUIBackups"; backups.Parent = ServerStorage end
 local backup = Instance.new("Folder"); backup.Name = "MobOverhead_" .. os.date("%Y-%m-%d_%H-%M-%S"); backup.Parent = backups
 old.Parent = backup
end
replacement.Parent = templates
Selection:Set({replacement})
print("MobOverhead saved. Scale-only layout. Save the place, then Play.")
