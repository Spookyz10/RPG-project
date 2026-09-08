local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Templates = require(UI.Bootstrap).GetTemplates()
local Windows = require(UI.WindowManager)
local UIFunctions = require(UI.UIFunctions)
local Dialog = {}
local dialogue
local body
local root
local session = 0
local finishTyping
local isTyped

function Dialog.IsOpen()
	return root ~= nil and root.Visible
end

function Dialog.Close()
	session += 1
	if finishTyping then finishTyping() end
	if root and root.Visible then Windows.Close() end
	dialogue = nil
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
	finishTyping, isTyped = UIFunctions:TypeText(body.Text, resolve(node.Text) or "", 0.018)
	local function addChoice(text, action, order)
		local button = Templates.DialogueChoiceTemplate:Clone()
		button.Name = "Choice"
		button.Text = text
		button.Parent = body.Options
		button.LayoutOrder = order
		button.Activated:Connect(function()
			if session ~= thisSession then return end
			if not isTyped() then finishTyping(); return end
			action()
		end)
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
end

function Dialog.Open(definition, npcName)
	dialogue = definition
	body.Speaker.Text = npcName
	Windows.Open("Dialogue")
	goTo(definition.GetStartNode and definition.GetStartNode(Constants.Data) or "Start")
end

function Dialog.Init()
	root = Constants.PlayerGui.Dialogue.Main
	body = root.Body.Content
	root:GetPropertyChangedSignal("Visible"):Connect(function()
		if not root.Visible then
			session += 1
			if finishTyping then finishTyping() end
		end
	end)
end

return Dialog
