local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local CurrentDialogue: Types.Dialogue? = nil
local CurrentNodeName: string? = nil
local SkipTyping: (() -> ())? = nil
local IsTypingComplete: (() -> boolean)? = nil
local OptionFrames: { GuiObject } = {}

local function ResolveText(text: string | ((Types.PlayerData) -> string), PlayerData: Types.PlayerData): string
	if typeof(text) == "function" then
		return text(PlayerData)
	end
	return text
end

local function ClearOptions()
	for _, Frame in OptionFrames do
		Frame:Destroy()
	end
	table.clear(OptionFrames)
end

function UI.Close()
	local DialogFrame = UIConstants.Main:FindFirstChild("Dialog")
	if DialogFrame then
		DialogFrame.Visible = false
	end

	ClearOptions()
	CurrentDialogue = nil
	CurrentNodeName = nil
	SkipTyping = nil
	IsTypingComplete = nil
end

local function ShowOptions(Options: { Types.DialogueOption }, PlayerData: Types.PlayerData)
	local DialogFrame = UIConstants.Main.Dialog
	local OptionsFrame = DialogFrame.Options
	local Template = ReplicatedStorage.Assets.UI.Templates.DialogOption

	for _, Option in Options do
		if Option.Condition and not Option.Condition(PlayerData) then
			continue
		end

		local Frame = Template:Clone() :: ImageButton
		Frame.Label.Text = ResolveText(Option.Text, PlayerData)

		Frame.MouseButton1Click:Connect(function()
			Option:Action(PlayerData, UI.Goto, UI.Close)
		end)

		Frame.Parent = OptionsFrame
		table.insert(OptionFrames, Frame)
	end
end

local function RenderNode(nodeName: string)
	if not CurrentDialogue then
		return
	end

	local Node = CurrentDialogue[nodeName]
	if not Node then
		warn("No dialogue node found for: ", nodeName)
		UI.Close()
		return
	end

	CurrentNodeName = nodeName
	ClearOptions()

	local DialogFrame = UIConstants.Main.Dialog
	local TextLabel = DialogFrame.Text :: TextLabel
	local PlayerData = UIConstants.Data :: Types.PlayerData

	local NodeText = ResolveText(Node.Text, PlayerData)

	SkipTyping, IsTypingComplete = UIFunctions:TypeText(TextLabel, NodeText, nil, function()
		if Node.Options then
			ShowOptions(Node.Options, PlayerData)
		end
	end)
end

function UI.Goto(nodeName: string)
	RenderNode(nodeName)
end

function UI.Open(dialogue: Types.Dialogue, startNode: string)
	CurrentDialogue = dialogue
	UIConstants.Main.Dialog.Visible = true
	RenderNode(startNode)
end

function UI.Init()
	local DialogFrame = UIConstants.Main.Dialog
	local ActionButton = DialogFrame.DialogueAction :: GuiButton

	ActionButton.MouseButton1Click:Connect(function()
		if not CurrentDialogue or not CurrentNodeName then
			return
		end

		if IsTypingComplete and not IsTypingComplete() then
			if SkipTyping then
				SkipTyping()
			end
			return
		end

		local Node = CurrentDialogue[CurrentNodeName]
		if not Node then
			return
		end

		if Node.Options then
			return
		end

		if Node.Next then
			UI.Goto(Node.Next)
		else
			UI.Close()
		end
	end)

	DialogFrame.Visible = false
end

return UI
