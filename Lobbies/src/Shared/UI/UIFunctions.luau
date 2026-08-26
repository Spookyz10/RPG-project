local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIFunctions = {}

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main") :: ScreenGui

local OpenUI: Frame = nil

local TypingSessions = {} :: { [TextLabel]: number }

function UIFunctions:ApplyRarityGradient(container: Instance, rarity: string)
	local CurrentGradient = container:FindFirstChildOfClass("UIGradient")
	if CurrentGradient then
		CurrentGradient:Destroy()
	end

	if not rarity then
		return
	end

	local RarityGradient = ReplicatedStorage.Assets.UI.Rarities:FindFirstChild(rarity) :: UIGradient?
	if not RarityGradient then
		return
	end

	RarityGradient:Clone().Parent = container
end

function UIFunctions:CloseUI()
	for _, frame in Main:GetChildren() do
		frame.Visible = false
	end

	OpenUI = nil
end

function UIFunctions:OpenUI(uiName: string)
	local Target = Main:FindFirstChild(uiName) :: Frame?

	if not Target then
		return
	end

	if OpenUI == Target then
		OpenUI.Visible = false
		OpenUI = nil
		return
	end

	if OpenUI then
		OpenUI.Visible = false
	end

	Target.Visible = true
	OpenUI = Target
end

function UIFunctions:TypeText(
	label: TextLabel,
	text: string,
	charDelay: number?,
	onComplete: (() -> ())?
): (() -> (), () -> boolean)
	TypingSessions[label] = (TypingSessions[label] or 0) + 1
	local Session = TypingSessions[label]

	local Delay = charDelay or 0.03
	local Completed = false

	label.Text = ""

	local function Finish()
		if Completed or TypingSessions[label] ~= Session then
			return
		end

		Completed = true
		label.Text = text

		if onComplete then
			onComplete()
		end
	end

	local function IsComplete(): boolean
		return Completed
	end

	task.spawn(function()
		for index = 1, #text do
			if TypingSessions[label] ~= Session then
				return
			end

			if Completed then
				return
			end

			label.Text = string.sub(text, 1, index)
			task.wait(Delay)
		end

		Finish()
	end)

	return Finish, IsComplete
end

return UIFunctions
