local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local TutorialCutscene = {}

local Pages = {
	"Welcome to RPG Simulator. This is a game where you defeat monsters to get loot and become more powerful. I will be giving you a quick tour of the lobby.",
	"Here we have the Item Shop. You can buy swords and potions here to help you out during your adventure. But you will earn better swords from defeating zone bosses.",
	"This is where you can craft Runes. Runes increase the power of some skills.",
	"This is the Zone Teleporter. You will start your adventure here and work your way up the zones to become more powerful. Monsters here will be dropping weapons and potions to boost your main stats.",
	"This is the Boss Teleporter. Once you're strong enough, enter here solo or with a party to defeat bosses and get legendary loot.",
	"Lastly, the World Teleporter. The moment you reach Level 250 you can teleport to World 2 and continue your journey.",
}

local TYPE_CHUNK = 16

local Playing = false

local function GetCharacter(): Model
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function HideOtherGuis(PlayerGui: PlayerGui, Except: ScreenGui)
	for _, Gui in PlayerGui:GetChildren() do
		if Gui:IsA("ScreenGui") and Gui ~= Except then
			Gui.Enabled = false
		end
	end
end

local function ShowAllGuis(PlayerGui: PlayerGui)
	for _, Gui in PlayerGui:GetChildren() do
		if Gui:IsA("ScreenGui") then
			Gui.Enabled = true
		end
	end
end

function TutorialCutscene:Play()
	if Playing then
		return
	end
	Playing = true

	local Character = GetCharacter()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	local Cameras = workspace:WaitForChild("Cameras")
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
	local TutorialUI = PlayerGui:WaitForChild("Tutorial") :: ScreenGui

	Humanoid.WalkSpeed = 0
	HideOtherGuis(PlayerGui, TutorialUI)
	TutorialUI.Enabled = true

	local CurrentCamera = workspace.CurrentCamera
	local TextLabel = TutorialUI.ImageLabel.Info.TextLabel :: TextLabel
	local OpenIndicator = TutorialUI.Open :: Frame
	local ClosedIndicator = TutorialUI.Closed :: Frame
	local NextButton = TutorialUI.ImageLabel.Info.Next :: TextButton

	local CurrentPage = 0
	local IsTyping = false
	local TypeSession = 0

	local function EndCutscene()
		ShowAllGuis(PlayerGui)
		TutorialUI:Destroy()

		Humanoid.WalkSpeed = 16
		CurrentCamera.CameraSubject = Humanoid
		CurrentCamera.CameraType = Enum.CameraType.Custom

		Playing = false
	end

	local function TypePage(Text: string)
		TypeSession += 1
		local Session = TypeSession

		IsTyping = true
		TextLabel.Text = ""

		for index = 1, #Text do
			if Session ~= TypeSession then
				return
			end

			OpenIndicator.Visible = index % TYPE_CHUNK ~= 0
			ClosedIndicator.Visible = not OpenIndicator.Visible

			TextLabel.Text = string.sub(Text, 1, index)
			task.wait()
		end

		IsTyping = false
	end

	local function GoToPage(pageIndex: number)
		local CameraPart = Cameras:FindFirstChild("C" .. pageIndex)
		if not CameraPart then
			return
		end

		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		CurrentCamera.CameraSubject = CameraPart
		CurrentCamera.CFrame = CameraPart.CFrame

		TypePage(Pages[pageIndex])
	end

	local function Advance()
		if IsTyping then
			TypeSession += 1
			TextLabel.Text = Pages[CurrentPage]
			IsTyping = false
			return
		end

		CurrentPage += 1

		if CurrentPage > #Pages then
			EndCutscene()
			return
		end

		GoToPage(CurrentPage)
	end

	NextButton.MouseButton1Click:Connect(Advance)

	Advance()
end

return TutorialCutscene
