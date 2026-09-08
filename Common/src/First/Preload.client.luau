local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Bootstrap = require(Shared:WaitForChild("UI"):WaitForChild("Bootstrap"))
local gui = Bootstrap.Ensure()
gui:SetAttribute("UIBlocking", true)
local screen = gui.LoadingScreen
local frame = screen.Frame
ReplicatedFirst:RemoveDefaultLoadingScreen()

local PreloadStatus = require(script.Parent:WaitForChild("PreloadStatus"))
local Data = require(Shared:WaitForChild("Data")).client
require(Shared.CollisionGroups)

if not game:IsLoaded() then
	game.Loaded:Wait()
end
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end)

-- Only preload assets, not every instance in the workspace.
local items = {}
local resources = ReplicatedStorage:FindFirstChild("Resources")
if resources then
	for _, item in resources:GetDescendants() do
		if item:IsA("Animation") or item:IsA("Sound") or item:IsA("MeshPart") or item:IsA("Decal") then
			table.insert(items, item)
		end
	end
end
local done = #items == 0
local completed = 0
local ready = false
task.spawn(function()
	if #items > 0 then
		pcall(function()
			ContentProvider:PreloadAsync(items, function()
				completed += 1
				if screen.Parent and not ready then
					local ratio = math.clamp(completed / #items, 0, 0.98)
					frame.Progress.Fill.Size = UDim2.fromScale(ratio, 1)
					frame.Status.Text = "Preparing your adventure... " .. math.floor(ratio * 100) .. "%"
				end
			end)
		end)
	end
	done = true
end)
local started = os.clock()
while not done and os.clock() - started < 15 do
	task.wait(0.1)
end
ready = true
PreloadStatus:MarkComplete()
frame.Progress.Fill.Size = UDim2.fromScale(1, 1)
frame.Status.Text = done and "Your adventure is ready." or "Ready to explore. Remaining assets will load as you play."
frame.Play.Visible = true

local entered = false
local keyConnection
local function enter()
	if entered then
		return
	end
	entered = true
	if keyConnection then
		keyConnection:Disconnect()
	end
	screen:Destroy()
	gui:SetAttribute("UIBlocking", false)
	local player = Players.LocalPlayer
	if player:GetAttribute("ShowTutorial") == true or Data.FirstTimeJoined() then
		require(Shared.TutorialCutscene):Play()
	end
end
frame.Play.Activated:Connect(enter)
keyConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonA) then
		enter()
	end
end)
