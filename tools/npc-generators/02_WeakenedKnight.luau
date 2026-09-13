assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the NPC.")

local Players = game:GetService("Players")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local History = game:GetService("ChangeHistoryService")

local NPC_NAME = "Weakened Knight"
local DEFAULT_GROUND_POSITION = Vector3.new(5, 0, 0)
local CATALOG_IDS = {
	Helmet = 105718269941739,
	Chest = 88828932123811,
	Waist = 123727343243085,
	Sword = 81298185096899,
	Bandage = 127751332628607,
	LeftShoulder = 114417014457175,
	RightShoulder = 137879576649316,
}

local function getFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("Folder"), parent:GetFullName() .. "." .. name .. " must be a Folder.")
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local npcFolder = getFolder(workspace, "NPCs")
local old = npcFolder:FindFirstChild(NPC_NAME)
assert(not old or old:IsA("Model"), "Workspace.NPCs.Weakened Knight must be a Model before it can be upgraded.")

local description = Instance.new("HumanoidDescription")
description.HeadColor = Color3.fromRGB(163, 113, 82)
description.LeftArmColor = Color3.fromRGB(68, 72, 78)
description.RightArmColor = Color3.fromRGB(68, 72, 78)
description.TorsoColor = Color3.fromRGB(42, 45, 50)
description.LeftLegColor = Color3.fromRGB(35, 37, 42)
description.RightLegColor = Color3.fromRGB(35, 37, 42)
description.HatAccessory = tostring(CATALOG_IDS.Helmet)
description.FrontAccessory = tostring(CATALOG_IDS.Chest)
description.WaistAccessory = tostring(CATALOG_IDS.Waist)
description.BackAccessory = tostring(CATALOG_IDS.Sword)
description.FaceAccessory = tostring(CATALOG_IDS.Bandage)
description.ShouldersAccessory = string.format("%d,%d", CATALOG_IDS.LeftShoulder, CATALOG_IDS.RightShoulder)
description.BodyTypeScale = 0.25
description.ProportionScale = 0
description.WidthScale = 0.96
description.DepthScale = 0.96

local ok, generated = pcall(function()
	return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
end)
description:Destroy()
assert(ok and generated, "Could not load the Weakened Knight catalog appearance: " .. tostring(generated))

local model = generated :: Model
model.Name = NPC_NAME
model:SetAttribute("GeneratedNPC", true)
model:SetAttribute("CatalogAccessories", string.format("%d,%d,%d,%d,%d,%d,%d", CATALOG_IDS.Helmet, CATALOG_IDS.Chest, CATALOG_IDS.Waist, CATALOG_IDS.Sword, CATALOG_IDS.Bandage, CATALOG_IDS.LeftShoulder, CATALOG_IDS.RightShoulder))
model:SetAttribute("InteractionName", "Weakened Knight")
model:SetAttribute("InteractionAction", "Talk")
model:SetAttribute("InteractionKey", "F")
model:SetAttribute("InteractionDistance", 18)
model:SetAttribute("InteractionColor", Color3.fromRGB(76, 184, 255))
model:SetAttribute("InteractionHighlightColor", Color3.fromRGB(76, 184, 255))
model:SetAttribute("InteractionOffset", Vector3.new(0, 3.5, 0))
local humanoid = model:FindFirstChildOfClass("Humanoid")
assert(humanoid, "The generated Weakened Knight has no Humanoid.")
humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
humanoid.WalkSpeed = 0
humanoid.AutoRotate = false
for _, descendant in model:GetDescendants() do
	if descendant:IsA("LuaSourceContainer") then
		descendant:Destroy()
	elseif descendant:IsA("BasePart") then
		descendant.Anchored = descendant.Name == "HumanoidRootPart"
		descendant.CanCollide = false
		descendant.CanTouch = false
	end
end
local rootPart = model:FindFirstChild("HumanoidRootPart")
assert(rootPart and rootPart:IsA("BasePart"), "The generated Weakened Knight has no HumanoidRootPart.")
model.PrimaryPart = rootPart

local groundPosition = DEFAULT_GROUND_POSITION
local rotation = CFrame.new()
if old then
	local oldBox, oldSize = old:GetBoundingBox()
	groundPosition = Vector3.new(oldBox.Position.X, oldBox.Position.Y - oldSize.Y / 2, oldBox.Position.Z)
	local oldPivot = old:GetPivot()
	rotation = oldPivot - oldPivot.Position
end
model:PivotTo(CFrame.new(groundPosition) * rotation)
local newBox, newSize = model:GetBoundingBox()
model:PivotTo(model:GetPivot() + Vector3.new(0, groundPosition.Y - (newBox.Position.Y - newSize.Y / 2), 0))

local recording
pcall(function() recording = History:TryBeginRecording("GenerateWeakenedKnightNPC", "Generate Weakened Knight NPC") end)
if old then
	local backupRoot = getFolder(ServerStorage, "NPCGeneratorBackups")
	local backup = Instance.new("Folder")
	backup.Name = NPC_NAME .. "_" .. os.date("%Y-%m-%d_%H-%M-%S")
	backup.Parent = backupRoot
	old.Parent = backup
end
model.Parent = npcFolder
Selection:Set({ model })
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Weakened Knight generated in Workspace.NPCs. Move the selected model to its final location and save the place.")
