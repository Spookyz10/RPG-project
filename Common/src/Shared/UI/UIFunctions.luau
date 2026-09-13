local Players = game:GetService("Players")

local UIFunctions = {}

local Windows = require(script.Parent.WindowManager)
local Toast = require(script.Parent.Toast)

local TypingSessions = {} :: { [TextLabel]: number }
local ShakeSizes = { 17, 14, 18, 15, 17, 16 }

local Theme = require(script.Parent.Theme)
local RarityColors = Theme.Rarities

UIFunctions.RarityColors = RarityColors

function UIFunctions:SetIcon(image: ImageLabel | ImageButton, icon: string?): boolean
	local hasIcon = typeof(icon) == "string" and icon ~= ""
	image.Image = hasIcon and icon or ""
	image.ImageTransparency = hasIcon and 0 or 1
	return hasIcon
end

local function renderDialogueMarkup(text: string, shakeSize: number?): string
	return string.gsub(text, "<shake>(.-)</shake>", function(content)
		if shakeSize then
			return string.format("<font size=\"%d\">%s</font>", shakeSize, content)
		end
		return content
	end)
end

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
	local ShakeStarted = false
	local ShakeStart
	local ShakeTagStart = string.find(text, "<shake>", 1, true)
	if ShakeTagStart then
		local beforeShake = renderDialogueMarkup(string.sub(text, 1, ShakeTagStart - 1))
		local visibleBefore = label.RichText and string.gsub(beforeShake, "<.->", "") or beforeShake
		ShakeStart = (utf8.len(visibleBefore) or #visibleBefore) + 1
	end

	label.Text = renderDialogueMarkup(text)
	label.MaxVisibleGraphemes = 0

	local function startShake()
		if ShakeStarted or not ShakeStart then return end
		ShakeStarted = true
		task.spawn(function()
			for _, size in ShakeSizes do
				if TypingSessions[label] ~= Session then return end
				label.Text = renderDialogueMarkup(text, size)
				task.wait(0.055)
			end
			if TypingSessions[label] == Session then
				label.Text = renderDialogueMarkup(text)
			end
		end)
	end

	local function Finish()
		if Completed or TypingSessions[label] ~= Session then
			return
		end

		Completed = true
		label.MaxVisibleGraphemes = -1
		startShake()

		if onComplete then
			onComplete()
		end
	end

	local function IsComplete(): boolean
		return Completed
	end

	task.spawn(function()
		local renderedText = renderDialogueMarkup(text)
		local visibleText = label.RichText and string.gsub(renderedText, "<.->", "") or renderedText
		local GraphemeCount = utf8.len(visibleText) or #visibleText

		for index = 1, GraphemeCount do
			if TypingSessions[label] ~= Session or Completed then
				return
			end

			label.MaxVisibleGraphemes = index
			if ShakeStart and index >= ShakeStart then startShake() end
			task.wait(Delay)
		end

		Finish()
	end)

	return Finish, IsComplete
end

return UIFunctions
