local Players = game:GetService("Players")

local UIFunctions = {}

local Windows = require(script.Parent.WindowManager)
local Toast = require(script.Parent.Toast)

local TypingSessions = {} :: { [TextLabel]: number }

local Theme = require(script.Parent.Theme)
local RarityColors = Theme.Rarities

UIFunctions.RarityColors = RarityColors

function UIFunctions:ApplyRarity(container: Instance, rarity: string)
	if container:IsA("GuiObject") then container.BackgroundColor3 = RarityColors[rarity] or Theme.Soft end
	local RarityTag = container:FindFirstChild("RarityTag") :: ImageLabel
	if RarityTag then
		RarityTag.ImageColor3 = RarityColors[rarity] or Theme.Soft
		RarityTag.BackgroundColor3 = RarityTag.ImageColor3
	end
end

function UIFunctions:CloseUI()
	Windows.Close()
end

function UIFunctions:OpenUI(uiName: string)
	if not Windows.Open(uiName, true) then
		Toast.Show("This service is not available yet.")
	end
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
