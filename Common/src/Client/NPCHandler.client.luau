local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Dialogues = require(ReplicatedStorage.Shared.Dialogues)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Windows = require(ReplicatedStorage.Shared.UI.WindowManager)
local Player = Players.LocalPlayer
local NPCs = workspace:WaitForChild("NPCs")
local registered = setmetatable({}, { __mode = "k" })

local function setup(npc)
	if not npc:IsA("Model") or not Dialogues[npc.Name] or registered[npc] then return end
	local part = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
	if not part then return end
	registered[npc] = true
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "RPGTalk"
	prompt.ActionText = "Talk"
	prompt.ObjectText = npc.Name
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.MaxActivationDistance = 18
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt.ClickablePrompt = true
	prompt.Parent = part
	local gui = Player:WaitForChild("PlayerGui")
	local function refresh()
		prompt.Enabled = not Windows.IsOpen() and not gui:GetAttribute("UIBlocking")
	end
	local state = gui:GetAttributeChangedSignal("UIWindowOpen"):Connect(refresh)
	local loading = gui:GetAttributeChangedSignal("UIBlocking"):Connect(refresh)
	prompt.Triggered:Connect(function()
		if not Windows.IsOpen() and not gui:GetAttribute("UIBlocking") then
			Logic.Dialog.Open(Dialogues[npc.Name], npc.Name)
		end
	end)
	npc.Destroying:Connect(function() state:Disconnect(); loading:Disconnect() end)
	refresh()
end

for _, npc in NPCs:GetChildren() do setup(npc) end
NPCs.ChildAdded:Connect(setup)
NPCs.DescendantAdded:Connect(function(part)
	if part:IsA("BasePart") then
		local npc = part:FindFirstAncestorWhichIsA("Model")
		if npc and npc.Parent == NPCs then setup(npc) end
	end
end)
