-- Binds saved Studio UI only. Screen construction lives in tools/ui-generators.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Layout = require(script.Parent.Layout)
local Bootstrap = {}
local ready = false

local screenNames = {
	"LoadingScreen", "HUD", "Buttons", "Attack", "Inventory", "SkillSelector",
	"ZoneSelector", "RaidsGUI", "Playerlist", "Partylist", "Dialogue", "Shop",
	"Journal", "Notifications", "Tutorial", "Main", "PlayerCard",
}

function Bootstrap.Ensure()
	assert(RunService:IsClient(), "Ensure binds the client UI; generate screens in Edit mode using tools/ui-generators.")
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	if ready then return gui end
	for _, name in screenNames do
		assert(gui:WaitForChild(name, 20), "Missing UI: " .. name .. ". Run the Edit-mode generators, then save the place.")
	end
	assert(ReplicatedStorage:WaitForChild("RPGUITemplates", 20), "Generate Templates in Edit mode before playing.")
	if ready then return gui end
	ready = true
	for _, screen in gui:GetChildren() do
		if screen:IsA("ScreenGui") then
			Layout.Bind(screen)
			require(script.Parent.Hover).BindScreen(screen)
			for _, object in screen:GetDescendants() do
				if object:IsA("GuiObject") and object:GetAttribute("Window") then object.Visible = false end
			end
		end
	end
	gui.Tutorial.Enabled = false
	if gui:FindFirstChild("UIStylePreview") then gui.UIStylePreview.Enabled = false end
	require(script.Parent.WindowManager).Bind(gui)
	return gui
end

function Bootstrap.GetTemplates()
	return ReplicatedStorage:WaitForChild("RPGUITemplates", 20)
end

return Bootstrap
