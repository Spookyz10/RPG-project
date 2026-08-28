local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local PreloadStatus = require(ReplicatedFirst:WaitForChild("First"):WaitForChild("PreloadStatus"))
local Data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data")).client
local TutorialCutscene = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TutorialCutscene"))

require(ReplicatedStorage:WaitForChild("Shared").CollisionGroups)

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Screen = PlayerGui:WaitForChild("LoadingScreen")
local Frame = Screen.Frame
local Play = Frame.Play
local Bar = Frame.Picture.Bar.Bar
local Bar2 = Frame.Picture.Bar2.Bar
local Overlay = Frame.Overlay
local Label = Frame.TextLabel
local Gradient = Overlay:WaitForChild("UIGradient")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)

local Resources = ReplicatedStorage:WaitForChild("Resources")
local Folders = { Resources:WaitForChild("Weapons"), Resources:WaitForChild("Animations"), workspace }

local AllItems = {}
for _, folder in Folders do
	for _, item in folder:GetDescendants() do
		table.insert(AllItems, item)
	end
end

local Total = #AllItems

local function UpdateProgress(percent: number)
	percent = math.clamp(percent, 0, 1)
	Bar.Size = UDim2.fromScale(percent, 1)
	Bar2.Size = UDim2.fromScale(1, -percent)
	Label.Text = math.floor(percent * 100) .. "%"
end

if Total > 0 then
	local Loaded = 0

	ContentProvider:PreloadAsync(AllItems, function()
		Loaded += 1

		if Screen.Parent then
			UpdateProgress(Loaded / Total)
		end
	end)

	UpdateProgress(1)
end

PreloadStatus:MarkComplete()
ReplicatedFirst:RemoveDefaultLoadingScreen()
Screen.Enabled = true
task.wait(0.2)

local Spinning = true
task.spawn(function()
	while Spinning do
		Gradient.Rotation += 7
		task.wait()
	end
end)

Label.Text = "Press any button to continue"
Overlay.Visible = true
Play.Visible = true

local Connection
Connection = UserInputService.InputBegan:Connect(function()
	Spinning = false
	Connection:Disconnect()
	Screen:Destroy()
	if Data.FirstTimeJoined() then
		TutorialCutscene:Play()
	end
end)
