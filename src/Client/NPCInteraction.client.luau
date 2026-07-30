local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Dialogues = require(ReplicatedStorage.Shared.Dialogues)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local NPCsFolder = workspace:WaitForChild("NPCs")
local NPCsGui = PlayerGui:WaitForChild("NPCs")

local INTERACT_RANGE = 30

local ActiveNPCs: { [Model]: boolean } = {}
local NearestNPC: Model? = nil

local function GetRootPart(): BasePart?
	local Character = Player.Character
	if not Character then
		return nil
	end
	return Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function SetNPCState(npc: Model, isActive: boolean)
	local Highlight = npc:FindFirstChildOfClass("Highlight")
	if Highlight then
		Highlight.Enabled = isActive
	end

	local NPCGui = NPCsGui:FindFirstChild(npc.Name)
	if NPCGui then
		NPCGui.Enabled = isActive
		NPCGui.NPCName.Enabled = isActive
	end
end

local function UpdateNPCs()
	local RootPart = GetRootPart()
	if not RootPart then
		NearestNPC = nil
		return
	end

	local NearestDistance = INTERACT_RANGE

	NearestNPC = nil

	for _, npc: Model in NPCsFolder:GetChildren() do
		if not npc:IsA("Model") or not npc.PrimaryPart then
			continue
		end

		local Distance = (npc.PrimaryPart.Position - RootPart.Position).Magnitude
		local InRange = Distance <= INTERACT_RANGE
		local WasActive = ActiveNPCs[npc] == true

		if InRange ~= WasActive then
			SetNPCState(npc, InRange)
			ActiveNPCs[npc] = InRange or nil
		end

		if InRange and Distance <= NearestDistance then
			NearestDistance = Distance
			NearestNPC = npc
		end
	end
end

local function OnInteract(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode ~= Enum.KeyCode.E then
		return
	end

	if not NearestNPC then
		return
	end

	local DialogLogic = Logic["Dialog"]
	if DialogLogic.IsOpen() then
		return
	end

	local NPCDialogue = Dialogues[NearestNPC.Name]
	if not NPCDialogue then
		return
	end

	DialogLogic.Open(NPCDialogue, "Start", NearestNPC.Name)
end

NPCsFolder.ChildRemoved:Connect(function(npc)
	ActiveNPCs[npc] = nil
	if NearestNPC == npc then
		NearestNPC = nil
	end
end)

UserInputService.InputBegan:Connect(OnInteract)

while true do
	UpdateNPCs()
	task.wait(0.1)
end
