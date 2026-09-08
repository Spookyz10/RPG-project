local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local TutorialCutscene = {}
local Playing = false

local Pages = {
	"Welcome to Rise Beyond! Explore colorful zones, defeat monsters, and collect equipment for your next adventure.",
	"Your backpack keeps your equipment, potions, and materials together. Tap an item to see what it does.",
	"Open Skills to choose your abilities. Each card shows its level requirement and available slots.",
	"Explore lets you choose a zone. Stronger places unlock as you level up.",
	"Boss raids are better together. Open Adventurers to inspect other players and invite them to your party.",
	"Talk to villagers for quests. Tap their Talk prompt, or press F on a keyboard. Your quest journal tracks the objectives.",
}

function TutorialCutscene:Play()
	if Playing then return end
	Playing = true
	local gui = require(ReplicatedStorage.Shared.UI.Bootstrap).Ensure()
	local screen = gui:FindFirstChild("Tutorial")
	if not screen then Playing = false; return end
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local camera = workspace.CurrentCamera
	local cameras = workspace:FindFirstChild("Cameras")
	local oldSpeed = humanoid.WalkSpeed
	local oldType = camera.CameraType
	local oldSubject = camera.CameraSubject
	local oldCFrame = camera.CFrame
	local states = {}
	for _, other in gui:GetChildren() do
		if other:IsA("ScreenGui") then
			states[other] = other.Enabled
			other.Enabled = other == screen
		end
	end
	gui:SetAttribute("UIBlocking", true)
	humanoid.WalkSpeed = 0
	local info = screen.ImageLabel.Info
	local page = 0
	local finishTyping
	local isTyped
	local connections = {}
	local finished = false
	local function finish()
		if finished then return end
		finished = true
		if finishTyping then finishTyping() end
		for _, connection in connections do connection:Disconnect() end
		for other, enabled in states do if other.Parent then other.Enabled = enabled end end
		screen.Enabled = false
		if humanoid.Parent then humanoid.WalkSpeed = oldSpeed end
		camera.CameraType = oldType
		camera.CameraSubject = oldSubject
		camera.CFrame = oldCFrame
		gui:SetAttribute("UIBlocking", false)
		LocalPlayer:SetAttribute("ShowTutorial", false)
		Playing = false
	end
	local function advance()
		if finishTyping and not isTyped() then finishTyping(); return end
		page += 1
		if page > #Pages then finish(); return end
		local part = cameras and cameras:FindFirstChild("C" .. page)
		if part and part:IsA("BasePart") then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = part.CFrame
		end
		info.Title.Text = "A new adventure · " .. page .. " / " .. #Pages
		info.Next.Text = page == #Pages and "Let's explore" or "Continue"
		finishTyping, isTyped = require(ReplicatedStorage.Shared.UI.UIFunctions):TypeText(info.TextLabel, Pages[page], 0.018)
	end
	table.insert(connections, info.Next.Activated:Connect(advance))
	table.insert(connections, info.Skip.Activated:Connect(finish))
	table.insert(connections, humanoid.Died:Connect(finish))
	table.insert(connections, LocalPlayer.CharacterAdded:Connect(finish))
	advance()
end

return TutorialCutscene
