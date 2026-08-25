local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dialogues = require(ReplicatedStorage.Shared.Dialogues)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local NPCsGui = PlayerGui:WaitForChild("NPCs")
local Templates = ReplicatedStorage.Assets.Misc

local NPCsFolder = workspace:WaitForChild("NPCs")

local function SetupNPC(npc: Instance)
	if not npc:IsA("Model") then
		return
	end

	if not Dialogues[npc.Name] then
		return
	end

	if not npc.PrimaryPart then
		npc:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	local Highlight = Templates.NPCHighlight:Clone()
	Highlight.Enabled = false
	Highlight.Parent = npc

	local Overhead = Templates.NPCOverhead:Clone()
	Overhead.Name = npc.Name
	Overhead.Enabled = false
	Overhead.Adornee = npc.PrimaryPart
	Overhead.NPCName.Adornee = npc.PrimaryPart
	Overhead.NPCName.Label.Text = npc.Name
	Overhead.Parent = NPCsGui
end

for _, npc in NPCsFolder:GetChildren() do
	SetupNPC(npc)
end

NPCsFolder.ChildAdded:Connect(SetupNPC)
