local UI = script.Parent.Parent
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Constants = require(UI.UIConstants)
local Templates = require(UI.Bootstrap).GetTemplates()
local Theme = require(UI.Theme)
local Windows = require(UI.WindowManager)
local UIFunctions = require(UI.UIFunctions)
local Dialog = {}
local dialogue
local body
local root
local speaker
local dialogueText
local session = 0
local finishTyping
local isTyped
local choiceTemplate
local dialogScale
local restingPosition
local closing = false
local closeTween

local function playOpenAnimation()
	if not root or not dialogScale then return end
	if closeTween then closeTween:Cancel(); closeTween = nil end
	closing = false
	local position = restingPosition or root.Position
	root.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale + 0.035, position.Y.Offset)
	root.GroupTransparency = 1
	dialogScale.Scale = 0.9
	TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = position,
		GroupTransparency = 0,
	}):Play()
	TweenService:Create(dialogScale, TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
end

function Dialog.IsOpen()
	return root ~= nil and root.Visible
end

function Dialog.Close()
	if closing then return end
	session += 1
	if finishTyping then finishTyping() end
	dialogue = nil
	if not root or not root.Visible then return end
	if not dialogScale or not root:IsA("CanvasGroup") then
		Windows.Close(true)
		return
	end
	closing = true
	TweenService:Create(dialogScale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.94,
	}):Play()
	closeTween = TweenService:Create(root, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		GroupTransparency = 1,
	})
	closeTween.Completed:Once(function()
		if closing and root.Visible then Windows.Close(true) end
	end)
	closeTween:Play()
end

local function resolve(value)
	return type(value) == "function" and value(Constants.Data) or value
end

local function goTo(nodeName)
	local node = dialogue and dialogue.Nodes[nodeName]
	if not node then Dialog.Close(); return end
	session += 1
	local thisSession = session
	if finishTyping then finishTyping() end
	for _, child in body.Options:GetChildren() do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	local choices = {}
	local skipTyping = body:FindFirstChild("SkipTyping")
	if skipTyping and skipTyping:IsA("GuiObject") then skipTyping.Visible = true end
	local function revealChoices()
		if session ~= thisSession then return end
		if skipTyping and skipTyping:IsA("GuiObject") then skipTyping.Visible = false end
		for index, button in choices do
			task.delay((index - 1) * 0.045, function()
				if session ~= thisSession or not button.Parent then return end
				button.Visible = true
				button.Active = true
				local scale = button:FindFirstChild("ChoiceScale") :: UIScale?
				local stroke = button:FindFirstChildOfClass("UIStroke")
				if scale then
					scale.Scale = 0.9
					TweenService:Create(scale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
				end
				button.BackgroundTransparency = 1
				button.TextTransparency = 1
				TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0,
					TextTransparency = 0,
				}):Play()
				if stroke then
					stroke.Transparency = 1
					TweenService:Create(stroke, TweenInfo.new(0.18), { Transparency = 0 }):Play()
				end
			end)
		end
	end
	finishTyping, isTyped = UIFunctions:TypeText(dialogueText, resolve(node.Text) or "", 0.015, revealChoices)
	local function addChoice(text, action, order)
		local button = choiceTemplate:Clone()
		button.Name = "Choice"
		button.Text = text
		button.RichText = true
		button.Visible = false
		button.Active = false
		button.Parent = body.Options
		button.LayoutOrder = order
		local scale = button:FindFirstChild("ChoiceScale") :: UIScale?
		local restingColor = button.BackgroundColor3
		local hoverTween
		local function hover(active)
			if not button.Active or (active and not UserInputService.MouseEnabled) then return end
			if hoverTween then hoverTween:Cancel() end
			hoverTween = TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
				BackgroundColor3 = active and Theme.Blue or restingColor,
			})
			hoverTween:Play()
			if scale then
				TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
					Scale = active and 1.025 or 1,
				}):Play()
			end
		end
		button.MouseEnter:Connect(function() hover(true) end)
		button.MouseLeave:Connect(function() hover(false) end)
		button.SelectionGained:Connect(function() hover(true) end)
		button.SelectionLost:Connect(function() hover(false) end)
		button.Activated:Connect(function()
			if session ~= thisSession then return end
			if not isTyped() then finishTyping(); return end
			action()
		end)
		table.insert(choices, button)
	end
	if node.Options then
		for index, option in node.Options do
			addChoice(resolve(option.Text), function()
				if option.Action then option.Action(dialogue, Constants.Data, goTo, Dialog.Close)
				elseif option.Next then goTo(resolve(option.Next))
				else Dialog.Close() end
			end, index)
		end
	else
		addChoice(node.Next and "Continue" or node.Action and "Continue" or "See you!", function()
			if node.Action then node.Action(dialogue, Constants.Data, goTo, Dialog.Close)
			elseif node.Next then goTo(resolve(node.Next))
			else Dialog.Close() end
		end, 1)
	end
	if isTyped() then revealChoices() end
end

function Dialog.Open(definition, npcName)
	if closing then
		if closeTween then closeTween:Cancel() end
		closing = false
	end
	dialogue = definition
	speaker.Text = npcName
	Windows.Open("Dialogue")
	playOpenAnimation()
	goTo(definition.GetStartNode and definition.GetStartNode(Constants.Data) or "Start")
end

function Dialog.Init()
	root = Constants.PlayerGui.Dialogue.Main
	body = root.Body.Content
	restingPosition = root.Position
	dialogScale = root:FindFirstChild("DialogScale") :: UIScale?
	speaker = body:FindFirstChild("Speaker") or root:FindFirstChild("Speaker", true)
	dialogueText = body:FindFirstChild("Text") or body:FindFirstChild("Text", true)
	assert(speaker and speaker:IsA("TextLabel"), "Dialogue requires a Speaker TextLabel")
	assert(dialogueText and dialogueText:IsA("TextLabel"), "Dialogue requires a Text TextLabel")
	dialogueText.RichText = true
	choiceTemplate = root:FindFirstChild("ChoiceTemplate") or Templates.DialogueChoiceTemplate
	local closeRequest = root:FindFirstChild("CloseRequest")
	if not closeRequest then
		closeRequest = Instance.new("BindableEvent")
		closeRequest.Name = "CloseRequest"
		closeRequest.Parent = root
	end
	if closeRequest:IsA("BindableEvent") then closeRequest.Event:Connect(Dialog.Close) end
	local close = root:FindFirstChild("Close")
	if close and close:IsA("GuiButton") then close.Activated:Connect(Dialog.Close) end
	local skipTyping = body:FindFirstChild("SkipTyping")
	if skipTyping and skipTyping:IsA("GuiButton") then
		skipTyping.Activated:Connect(function()
			if finishTyping and isTyped and not isTyped() then finishTyping() end
		end)
	end
	root:GetPropertyChangedSignal("Visible"):Connect(function()
		if not root.Visible then
			closing = false
			session += 1
			if finishTyping then finishTyping() end
		end
	end)
end

return Dialog
