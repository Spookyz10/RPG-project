local Manager = {}
local windows = {}
local playerGui
local current

function Manager.Close()
	if current then current.Visible = false end
	current = nil
	if playerGui then playerGui:SetAttribute("UIWindowOpen", false) end
end

function Manager.Open(screenName, toggle)
	local target = windows[screenName]
	if not target then return false end
	if current == target and toggle then Manager.Close(); return true end
	Manager.Close()
	current = target
	target.Visible = true
	playerGui:SetAttribute("UIWindowOpen", true)
	return true
end

function Manager.IsOpen()
	return playerGui ~= nil and playerGui:GetAttribute("UIWindowOpen") == true
end

function Manager.CloseScreen(screenName)
	if current == windows[screenName] then Manager.Close() end
end

function Manager.Bind(gui)
	playerGui = gui
	local function bind(object)
		if not object:IsA("GuiObject") or not object:GetAttribute("Window") then return end
		local screen = object:FindFirstAncestorWhichIsA("ScreenGui")
		windows[screen.Name] = object
		local close = object:FindFirstChild("Close")
		if close and close:IsA("GuiButton") then close.Activated:Connect(Manager.Close) end
		object:GetPropertyChangedSignal("Visible"):Connect(function()
			if not object.Visible and current == object then
				current = nil
				gui:SetAttribute("UIWindowOpen", false)
			end
		end)
	end
	for _, object in gui:GetDescendants() do bind(object) end
	gui.DescendantAdded:Connect(bind)
	game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Escape then Manager.Close() end
	end)
end

return Manager
