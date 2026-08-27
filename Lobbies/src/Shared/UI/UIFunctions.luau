local Players = game:GetService("Players")

local UIFunctions = {}

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main") :: ScreenGui

local OpenUI: Frame = nil

local TypingSessions = {} :: { [TextLabel]: number }

local RarityColors = {
	["Common"] = Color3.fromRGB(254, 255, 183),
	["Uncommon"] = Color3.fromRGB(0, 255, 0),
	["Rare"] = Color3.fromRGB(0, 255, 255),
	["Legendary"] = Color3.fromRGB(255, 0, 166),
	["Godly"] = Color3.fromRGB(255, 213, 0),
	["Ascendant"] = Color3.fromRGB(106, 0, 255),
}

UIFunctions.RarityColors = RarityColors

function UIFunctions:ApplyRarity(container: Instance, rarity: string)
	local RarityTag = container:FindFirstChild("RarityTag") :: ImageLabel
	if RarityTag then
		RarityTag.ImageColor3 = RarityColors[rarity]
	end
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

	label.Text = text
	label.MaxVisibleGraphemes = 0

	local function Finish()
		if Completed or TypingSessions[label] ~= Session then
			return
		end

		Completed = true
		label.MaxVisibleGraphemes = -1

		if onComplete then
			onComplete()
		end
	end

	local function IsComplete(): boolean
		return Completed
	end

	task.spawn(function()
		local GraphemeCount = utf8.len(text) or #text

		for index = 1, GraphemeCount do
			if TypingSessions[label] ~= Session or Completed then
				return
			end

			label.MaxVisibleGraphemes = index
			task.wait(Delay)
		end

		Finish()
	end)

	return Finish, IsComplete
end

return UIFunctions
