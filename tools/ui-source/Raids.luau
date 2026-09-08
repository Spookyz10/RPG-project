local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, _, body = C.Window(parent, "RaidsGUI", "Main", "Something bigger awaits", "Choose a boss and bring your party.", 560, 900)
	local tabs = C.Frame(body, "RaidTypes", UDim2.new(), UDim2.new(1, 0, 0, 48))
	C.Button(tabs, "Standard", "Standard raids", UDim2.new(), UDim2.fromOffset(170, 48), T.Sand)
	local containers = C.Frame(body, "RaidContainers", UDim2.fromOffset(0, 60), UDim2.new(1, 0, 1, -60))
	local list = C.Scroll(containers, "RaidList", UDim2.new(), UDim2.new(0.34, -12, 1, 0))
	C.Responsive(list, UDim2.new(), UDim2.new(0.34, -12, 1, 0), UDim2.new(), UDim2.new(1, 0, 0, 190))
	local display = C.Frame(containers, "RaidDisplay")
	C.Responsive(display, UDim2.fromScale(0.34, 0), UDim2.fromScale(0.66, 1), UDim2.fromOffset(0, 206), UDim2.new(1, 0, 0, 630))
	local clicked = C.Frame(display, "Clicked")
	C.Label(clicked, "Raid", "Select a raid", UDim2.new(), UDim2.new(1, 0, 0, 28), true).TextSize = 22
	local picture = C.Image(clicked, "Picture", UDim2.fromOffset(0, 36), UDim2.new(1, 0, 0, 140))
	picture.BackgroundTransparency = 0
	picture.BackgroundColor3 = T.Sky
	C.Round(picture)
	C.Label(picture, "Warning", "BOSS", UDim2.fromOffset(8, 8), UDim2.fromOffset(64, 24), true).TextColor3 = T.Red
	local info = C.Frame(clicked, "Info", UDim2.fromOffset(0, 182), UDim2.new(1, 0, 0, 30))
	for index, entry in { { "Time", "Best time" }, { "Runs", "Runs" } } do
		local cell = C.Frame(info, entry[1], UDim2.new((index - 1) * 0.5, 0, 0, 0), UDim2.fromScale(0.5, 1))
		C.Label(cell, "Label", entry[2], UDim2.new(), UDim2.fromScale(0.5, 1)).TextSize = 12
		C.Label(cell, entry[1], "--", UDim2.fromScale(0.5, 0), UDim2.fromScale(0.5, 1), true)
	end
	local mode = C.Frame(clicked, "Mode", UDim2.fromOffset(0, 218), UDim2.new(1, 0, 0, 52))
	C.Label(mode, "Current", "Mode: Normal", UDim2.new(), UDim2.new(0.55, 0, 1, 0), true).RichText = true
	local switchFrame = C.Frame(mode, "Frame", UDim2.fromScale(0.55, 0), UDim2.fromScale(0.45, 1))
	C.Button(switchFrame, "Switch", "Change", UDim2.new(), UDim2.new(1, 0, 0, 48), T.Sky)
	C.Label(clicked, "Warning", "Harder enemies. Prepare before entering!", UDim2.fromOffset(0, 274), UDim2.new(1, 0, 0, 32)).TextColor3 = T.Red
	local rewards = C.Frame(clicked, "Rewards", UDim2.fromOffset(0, 310), UDim2.new(1, 0, 0, 128))
	C.Label(rewards, "Label", "LOOT · tap to toggle auto-delete", UDim2.new(), UDim2.new(1, 0, 0, 24)).TextSize = 12
	C.Scroll(rewards, "ScrollingFrame", UDim2.fromOffset(0, 28), UDim2.new(1, 0, 1, -28), 72, 84)
	C.Button(clicked, "Enter", "Enter raid", UDim2.fromOffset(0, 446), UDim2.new(1, 0, 0, 52), T.Sand)
	return screen
end
