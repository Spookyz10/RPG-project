assert(not game:GetService("RunService"):IsRunning(), "Stop Play before capturing the Studio UI.")

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local INCLUDE_TEMPLATES = false
local SCREEN_FILTER = {
	Inventory = true,
	PlayerCard = true,
}
local MAX_PRINT_CHARS = 12000
local GENERATED_BY = "CodexUIDumpV2"

local BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64Encode(input)
	local output = {}
	for index = 1, #input, 3 do
		local first = string.byte(input, index)
		local second = string.byte(input, index + 1)
		local third = string.byte(input, index + 2)
		local value = first * 65536 + (second or 0) * 256 + (third or 0)

		table.insert(output, BASE64:sub(bit32.rshift(value, 18) % 64 + 1, bit32.rshift(value, 18) % 64 + 1))
		table.insert(output, BASE64:sub(bit32.rshift(value, 12) % 64 + 1, bit32.rshift(value, 12) % 64 + 1))
		table.insert(output, second and BASE64:sub(bit32.rshift(value, 6) % 64 + 1, bit32.rshift(value, 6) % 64 + 1) or "=")
		table.insert(output, third and BASE64:sub(value % 64 + 1, value % 64 + 1) or "=")
	end
	return table.concat(output)
end

local function number(value)
	return string.format("%.5g", value)
end

local function valueToString(value)
	local kind = typeof(value)
	if kind == "string" then return string.format("%q", value) end
	if kind == "number" then return number(value) end
	if kind == "boolean" or kind == "nil" then return tostring(value) end
	if kind == "Color3" then
		return string.format("Color3.fromRGB(%d, %d, %d)", math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255))
	end
	if kind == "Vector2" then return "Vector2.new(" .. number(value.X) .. ", " .. number(value.Y) .. ")" end
	if kind == "Vector3" then return "Vector3.new(" .. number(value.X) .. ", " .. number(value.Y) .. ", " .. number(value.Z) .. ")" end
	if kind == "CFrame" then
		local values = { value:GetComponents() }
		for index, component in values do values[index] = number(component) end
		return "CFrame.new(" .. table.concat(values, ", ") .. ")"
	end
	if kind == "UDim" then return "UDim.new(" .. number(value.Scale) .. ", " .. value.Offset .. ")" end
	if kind == "UDim2" then
		return "UDim2.new(" .. number(value.X.Scale) .. ", " .. value.X.Offset .. ", " .. number(value.Y.Scale) .. ", " .. value.Y.Offset .. ")"
	end
	if kind == "Rect" then return "Rect.new(" .. valueToString(value.Min) .. ", " .. valueToString(value.Max) .. ")" end
	if kind == "EnumItem" then return tostring(value) end
	if kind == "NumberRange" then return "NumberRange.new(" .. number(value.Min) .. ", " .. number(value.Max) .. ")" end
	if kind == "Font" then
		return "Font.new(" .. string.format("%q", value.Family) .. ", " .. tostring(value.Weight) .. ", " .. tostring(value.Style) .. ")"
	end
	if kind == "ColorSequence" then
		local points = {}
		for _, point in value.Keypoints do
			table.insert(points, "ColorSequenceKeypoint.new(" .. number(point.Time) .. ", " .. valueToString(point.Value) .. ")")
		end
		return "ColorSequence.new({ " .. table.concat(points, ", ") .. " })"
	end
	if kind == "NumberSequence" then
		local points = {}
		for _, point in value.Keypoints do
			table.insert(points, "NumberSequenceKeypoint.new(" .. number(point.Time) .. ", " .. number(point.Value) .. ", " .. number(point.Envelope) .. ")")
		end
		return "NumberSequence.new({ " .. table.concat(points, ", ") .. " })"
	end
	return string.format("%q", tostring(value))
end

local function collect(object, names)
	local values = {}
	for _, property in names do
		local ok, value = pcall(function() return object[property] end)
		if ok then values[property] = valueToString(value) end
	end
	return values
end

local baseProperties = { "Archivable", "Enabled", "ResetOnSpawn", "DisplayOrder", "ZIndexBehavior", "IgnoreGuiInset", "ScreenInsets" }
local guiProperties = {
	"Active", "AnchorPoint", "AutomaticSize", "BackgroundColor3", "BackgroundTransparency", "BorderColor3",
	"BorderMode", "BorderSizePixel", "ClipsDescendants", "Interactable", "LayoutOrder", "Position", "Rotation",
	"Selectable", "SelectionImageObject", "Size", "SizeConstraint", "Visible", "ZIndex",
}
local textProperties = {
	"Font", "FontFace", "LineHeight", "MaxVisibleGraphemes", "RichText", "Text", "TextColor3", "TextDirection",
	"TextScaled", "TextSize", "TextStrokeColor3", "TextStrokeTransparency", "TextTransparency", "TextTruncate",
	"TextWrapped", "TextXAlignment", "TextYAlignment",
}
local imageProperties = {
	"Image", "ImageColor3", "ImageRectOffset", "ImageRectSize", "ImageTransparency", "ResampleMode", "ScaleType",
	"SliceCenter", "SliceScale", "TileSize",
}
local scrollingProperties = {
	"AutomaticCanvasSize", "CanvasPosition", "CanvasSize", "ElasticBehavior", "ScrollBarImageColor3",
	"ScrollBarImageTransparency", "ScrollBarInset", "ScrollBarThickness", "ScrollingDirection", "VerticalScrollBarInset",
}
local layoutProperties = { "FillDirection", "HorizontalAlignment", "Padding", "SortOrder", "VerticalAlignment", "Wraps" }

local function node(object)
	local result = {
		class = object.ClassName,
		name = object.Name,
		attributes = {},
		properties = {},
		children = {},
	}
	for key, value in object:GetAttributes() do result.attributes[key] = valueToString(value) end
	if object:IsA("ScreenGui") then
		result.properties = collect(object, baseProperties)
	elseif object:IsA("GuiObject") then
		result.properties = collect(object, guiProperties)
	end
	if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
		for key, value in collect(object, textProperties) do result.properties[key] = value end
	end
	if object:IsA("TextButton") or object:IsA("ImageButton") then
		for key, value in collect(object, { "AutoButtonColor", "Modal", "Selected", "Style" }) do result.properties[key] = value end
	end
	if object:IsA("TextBox") then
		for key, value in collect(object, { "ClearTextOnFocus", "CursorPosition", "MultiLine", "PlaceholderColor3", "PlaceholderText", "SelectionStart", "ShowNativeInput", "TextEditable" }) do result.properties[key] = value end
	end
	if object:IsA("ImageLabel") or object:IsA("ImageButton") then
		for key, value in collect(object, imageProperties) do result.properties[key] = value end
	end
	if object:IsA("CanvasGroup") then
		for key, value in collect(object, { "GroupColor3", "GroupTransparency" }) do result.properties[key] = value end
	end
	if object:IsA("ViewportFrame") then
		for key, value in collect(object, { "Ambient", "ImageColor3", "ImageTransparency", "LightColor", "LightDirection" }) do result.properties[key] = value end
	end
	if object:IsA("ScrollingFrame") then
		for key, value in collect(object, scrollingProperties) do result.properties[key] = value end
	elseif object:IsA("UIListLayout") then
		result.properties = collect(object, layoutProperties)
	elseif object:IsA("UIGridLayout") then
		result.properties = collect(object, { "CellPadding", "CellSize", "FillDirection", "FillDirectionMaxCells", "HorizontalAlignment", "SortOrder", "StartCorner", "VerticalAlignment" })
	elseif object:IsA("UIStroke") then
		result.properties = collect(object, { "ApplyStrokeMode", "Color", "LineJoinMode", "Thickness", "Transparency" })
	elseif object:IsA("UICorner") then
		result.properties = collect(object, { "CornerRadius" })
	elseif object:IsA("UIGradient") then
		result.properties = collect(object, { "Color", "Enabled", "Offset", "Rotation", "Transparency" })
	elseif object:IsA("UIPadding") then
		result.properties = collect(object, { "PaddingBottom", "PaddingLeft", "PaddingRight", "PaddingTop" })
	elseif object:IsA("UIScale") then
		result.properties = collect(object, { "Scale" })
	elseif object:IsA("UIAspectRatioConstraint") then
		result.properties = collect(object, { "AspectRatio", "AspectType", "DominantAxis" })
	elseif object:IsA("UISizeConstraint") then
		result.properties = collect(object, { "MaxSize", "MinSize" })
	elseif object:IsA("UITextSizeConstraint") then
		result.properties = collect(object, { "MaxTextSize", "MinTextSize" })
	elseif object:IsA("Camera") then
		result.properties = collect(object, { "CFrame", "FieldOfView", "FieldOfViewMode" })
	end
	for _, child in object:GetChildren() do
		if not child:IsA("LuaSourceContainer") then table.insert(result.children, node(child)) end
	end
	table.sort(result.children, function(a, b)
		return a.class == b.class and a.name < b.name or a.class < b.class
	end)
	return result
end

local capture = {
	format = "Codex UI snapshot v1",
	place = game.Name,
	timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	templates = {},
	screens = {},
}

if INCLUDE_TEMPLATES then
	local templates = ReplicatedStorage:FindFirstChild("RPGUITemplates")
	if templates then capture.templates = node(templates) else capture.templates = { missing = true } end
end

for _, screen in StarterGui:GetChildren() do
	if screen:IsA("ScreenGui") and SCREEN_FILTER[screen.Name] then table.insert(capture.screens, node(screen)) end
end
table.sort(capture.screens, function(a, b) return a.name < b.name end)

local output = HttpService:JSONEncode(capture)
local root = ServerStorage:FindFirstChild("CodexUIDumps") or Instance.new("Folder")
root.Name = "CodexUIDumps"
root.Parent = ServerStorage
for _, child in root:GetChildren() do
	if child:GetAttribute("GeneratedBy") == GENERATED_BY then child:Destroy() end
end

local encoded = base64Encode(output)
for index = 1, math.ceil(#encoded / MAX_PRINT_CHARS) do
	local first = (index - 1) * MAX_PRINT_CHARS + 1
	local chunk = encoded:sub(first, first + MAX_PRINT_CHARS - 1)
	local stored = Instance.new("StringValue")
	stored.Name = string.format("Base64Chunk_%03d_of_%03d", index, math.ceil(#encoded / MAX_PRINT_CHARS))
	stored.Value = chunk
	stored:SetAttribute("GeneratedBy", GENERATED_BY)
	stored.Parent = root
	print(string.format("=== CODEX_UI_DUMP_BASE64 %d/%d ===\n%s", index, math.ceil(#encoded / MAX_PRINT_CHARS), chunk))
end

print("UI dump complete: " .. #output .. " JSON characters in " .. #root:GetChildren() .. " Base64 chunks.")
print("Copy every CODEX_UI_DUMP_BASE64 block from Output, or copy StringValues from ServerStorage.CodexUIDumps.")
