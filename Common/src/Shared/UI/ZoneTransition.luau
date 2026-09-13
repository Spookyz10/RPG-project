local TweenService = game:GetService("TweenService")
local Bootstrap = require(script.Parent.Bootstrap)

local Transition = {}
local busy = false

local function visualProperties(object: Instance): { string }
	local properties = {}
	if object:IsA("GuiObject") then table.insert(properties, "BackgroundTransparency") end
	if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
		table.insert(properties, "TextTransparency")
		table.insert(properties, "TextStrokeTransparency")
	end
	if object:IsA("ImageLabel") or object:IsA("ImageButton") then table.insert(properties, "ImageTransparency") end
	if object:IsA("UIStroke") then table.insert(properties, "Transparency") end
	return properties
end

local function capture(root: Instance)
	local snapshots = {}
	local objects = { root }
	for _, object in root:GetDescendants() do table.insert(objects, object) end
	for _, object in objects do
		local values = {}
		for _, property in visualProperties(object) do values[property] = (object :: any)[property] end
		if next(values) then table.insert(snapshots, { Object = object, Values = values }) end
	end
	return snapshots
end

local function hide(snapshots)
	for _, snapshot in snapshots do
		for property in snapshot.Values do (snapshot.Object :: any)[property] = 1 end
	end
end

local function tween(snapshots, visible: boolean, duration: number): Tween?
	local first
	for _, snapshot in snapshots do
		if snapshot.Object.Parent then
			local goal = {}
			for property, value in snapshot.Values do goal[property] = visible and value or 1 end
			local animation = TweenService:Create(snapshot.Object, TweenInfo.new(duration, Enum.EasingStyle.Quad), goal)
			first = first or animation
			animation:Play()
		end
	end
	return first
end

local function restore(snapshots)
	for _, snapshot in snapshots do
		if snapshot.Object.Parent then
			for property, value in snapshot.Values do (snapshot.Object :: any)[property] = value end
		end
	end
end

function Transition.Play(destination: string, onCovered: (() -> ())?)
	if busy then return end
	busy = true
	local screen = Bootstrap.Ensure().ZoneTransition
	local veil = screen.Veil
	veil.Panel.Title.Text = string.upper(destination)
	local snapshots = capture(veil)
	hide(snapshots)
	screen.Enabled = true
	local cover = tween(snapshots, true, 0.25)
	if cover then cover.Completed:Wait() end
	if onCovered then
		local ok, err = pcall(onCovered)
		if not ok then warn("Zone transition callback failed:", err) end
	end
	task.wait(0.12)
	local reveal = tween(snapshots, false, 0.3)
	if reveal then reveal.Completed:Wait() end
	screen.Enabled = false
	restore(snapshots)
	busy = false
end

return Transition
