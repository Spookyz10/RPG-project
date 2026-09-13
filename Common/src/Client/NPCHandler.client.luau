local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Dialogues = require(ReplicatedStorage.Shared.Dialogues)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Theme = require(ReplicatedStorage.Shared.UI.Theme)
local Windows = require(ReplicatedStorage.Shared.UI.WindowManager)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local NPCs = workspace:WaitForChild("NPCs")
local Templates = ReplicatedStorage:WaitForChild("RPGUITemplates")
local PromptTemplate = Templates:FindFirstChild("NPCInteractionTemplate")

if not PromptTemplate or not PromptTemplate:IsA("BillboardGui") then
	warn(
		"NPC interactions require RPGUITemplates.NPCInteractionTemplate. Run tools/ui-generators/34_NPCInteractionTemplate.luau in Studio."
	)
	return
end

type NPCInteraction = {
	NPC: Model,
	Part: BasePart,
	Highlight: Highlight,
	Prompt: BillboardGui,
	Connections: { RBXScriptConnection },
}

local registered = setmetatable({}, { __mode = "k" }) :: { [Model]: NPCInteraction }
local focused: NPCInteraction? = nil
local elapsed = 0

local function getNumberAttribute(npc: Model, name: string, default: number): number
	local value = npc:GetAttribute(name)
	return type(value) == "number" and value or default
end

local function getStringAttribute(npc: Model, name: string, default: string): string
	local value = npc:GetAttribute(name)
	return type(value) == "string" and value ~= "" and value or default
end

local function getColorAttribute(npc: Model, name: string, default: Color3): Color3
	local value = npc:GetAttribute(name)
	return typeof(value) == "Color3" and value or default
end

local function getVectorAttribute(npc: Model, name: string, default: Vector3): Vector3
	local value = npc:GetAttribute(name)
	return typeof(value) == "Vector3" and value or default
end

local function isAvailable(interaction: NPCInteraction): boolean
	return interaction.NPC.Parent == NPCs
		and interaction.NPC:GetAttribute("InteractionEnabled") ~= false
		and not Windows.IsOpen()
		and not PlayerGui:GetAttribute("UIBlocking")
end

local function inputLabel(npc: Model): string
	local custom = npc:GetAttribute("InteractionKeyLabel")
	if type(custom) == "string" and custom ~= "" then
		return custom
	end
	if UserInputService.TouchEnabled then
		return "TAP"
	end
	if UserInputService.GamepadEnabled then
		return getStringAttribute(npc, "InteractionGamepadLabel", "X")
	end
	return getStringAttribute(npc, "InteractionKey", "F")
end

local function applyAppearance(interaction: NPCInteraction)
	local npc = interaction.NPC
	local prompt = interaction.Prompt
	local main = prompt.Main
	local color = getColorAttribute(npc, "InteractionColor", Theme.Sky)
	local highlightColor = getColorAttribute(npc, "InteractionHighlightColor", Theme.Gold)
	prompt.StudsOffsetWorldSpace = getVectorAttribute(npc, "InteractionOffset", Vector3.new(0, 3.5, 0))
	main.NPCName.Text = getStringAttribute(npc, "InteractionName", npc.Name)
	main.Action.Text = getStringAttribute(npc, "InteractionAction", "Talk")
	main.Key.Text = inputLabel(npc)
	main.Key.BackgroundColor3 = color
	interaction.Highlight.FillColor = highlightColor
	interaction.Highlight.OutlineColor = highlightColor
	interaction.Highlight.FillTransparency = getNumberAttribute(npc, "InteractionHighlightFillTransparency", 0.82)
	interaction.Highlight.OutlineTransparency = getNumberAttribute(npc, "InteractionHighlightOutlineTransparency", 0.05)
end

local function hide(interaction: NPCInteraction)
	interaction.Highlight.Enabled = false
	interaction.Prompt.Enabled = false
end

local function setFocused(nextFocused: NPCInteraction?)
	if focused == nextFocused then
		return
	end
	if focused then
		hide(focused)
	end
	focused = nextFocused
	if not focused then
		return
	end
	applyAppearance(focused)
	local prompt = focused.Prompt
	local main = prompt.Main
	prompt.Enabled = true
	focused.Highlight.Enabled = true
	main.GroupTransparency = 1
	main.PromptScale.Scale = 0.82
	TweenService:Create(main, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
	}):Play()
	TweenService:Create(main.PromptScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
end

local function openFocused()
	local interaction = focused
	if not interaction or not isAvailable(interaction) then
		return
	end
	Logic.Dialog.Open(
		Dialogues[interaction.NPC.Name],
		getStringAttribute(interaction.NPC, "InteractionName", interaction.NPC.Name)
	)
	setFocused(nil)
end

local function setup(npc: Instance)
	if not npc:IsA("Model") or not Dialogues[npc.Name] or registered[npc] then
		return
	end
	local part = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
	if not part or not part:IsA("BasePart") then
		return
	end

	for _, oldPrompt in npc:GetDescendants() do
		if oldPrompt:IsA("ProximityPrompt") and oldPrompt.Name == "RPGTalk" then
			oldPrompt:Destroy()
		end
	end
	local highlight = Instance.new("Highlight")
	highlight.Name = "NPCInteractionHighlight"
	highlight.Adornee = npc
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Parent = npc

	local prompt = PromptTemplate:Clone()
	prompt.Name = "NPCInteraction"
	prompt.Adornee = part
	prompt.Enabled = false
	prompt.ResetOnSpawn = false
	prompt.Parent = PlayerGui

	local interaction: NPCInteraction = {
		NPC = npc,
		Part = part,
		Highlight = highlight,
		Prompt = prompt,
		Connections = {},
	}
	registered[npc] = interaction
	table.insert(interaction.Connections, prompt.Main.Tap.Activated:Connect(openFocused))
	table.insert(
		interaction.Connections,
		npc.Destroying:Connect(function()
			if focused == interaction then
				setFocused(nil)
			end
			for _, connection in interaction.Connections do
				connection:Disconnect()
			end
			prompt:Destroy()
			registered[npc] = nil
		end)
	)
end

for _, npc in NPCs:GetChildren() do
	setup(npc)
end
NPCs.ChildAdded:Connect(setup)
NPCs.DescendantAdded:Connect(function(part)
	if part:IsA("BasePart") then
		local npc = part:FindFirstAncestorWhichIsA("Model")
		if npc and npc.Parent == NPCs then
			setup(npc)
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or UserInputService:GetFocusedTextBox() then
		return
	end
	local interaction = focused
	if not interaction then
		return
	end
	local npc = interaction.NPC
	local key = Enum.KeyCode[getStringAttribute(npc, "InteractionKey", "F")]
	local gamepadKey = Enum.KeyCode[getStringAttribute(npc, "InteractionGamepadKey", "ButtonX")]
	if input.KeyCode == key or input.KeyCode == gamepadKey then
		openFocused()
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	elapsed += deltaTime
	if elapsed < 0.12 then
		return
	end
	elapsed = 0
	if Windows.IsOpen() or PlayerGui:GetAttribute("UIBlocking") then
		setFocused(nil)
		return
	end
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		setFocused(nil)
		return
	end
	local nearest: NPCInteraction? = nil
	local nearestDistance = math.huge
	for _, interaction in registered do
		if isAvailable(interaction) then
			local distance = (interaction.Part.Position - root.Position).Magnitude
			if
				distance <= getNumberAttribute(interaction.NPC, "InteractionDistance", 18)
				and distance < nearestDistance
			then
				nearest = interaction
				nearestDistance = distance
			end
		end
	end
	setFocused(nearest)
end)
