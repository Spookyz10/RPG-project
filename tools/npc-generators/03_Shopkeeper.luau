assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the NPC.")

local Players = game:GetService("Players")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local History = game:GetService("ChangeHistoryService")

local NPC_NAME = "Shopkeeper"
local DEFAULT_GROUND_POSITION = Vector3.new(15, 0, 0)
local CATALOG_IDS = {
	Apron = 100195419469482,
	Beard = 135122399154730,
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
assert(not old or old:IsA("Model"), "Workspace.NPCs.Shopkeeper must be a Model before it can be upgraded.")

local description = Instance.new("HumanoidDescription")
description.HeadColor = Color3.fromRGB(174, 120, 86)
description.LeftArmColor = Color3.fromRGB(174, 120, 86)
description.RightArmColor = Color3.fromRGB(174, 120, 86)
description.TorsoColor = Color3.fromRGB(42, 112, 104)
description.LeftLegColor = Color3.fromRGB(48, 40, 36)
description.RightLegColor = Color3.fromRGB(48, 40, 36)
description.FrontAccessory = tostring(CATALOG_IDS.Apron)
description.FaceAccessory = tostring(CATALOG_IDS.Beard)
description.BodyTypeScale = 0.15
description.ProportionScale = 0
description.WidthScale = 1.08
description.DepthScale = 1.08

local ok, generated = pcall(function()
	return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
end)
description:Destroy()
assert(ok and generated, "Could not load the Shopkeeper catalog appearance: " .. tostring(generated))

local model = generated :: Model
model.Name = NPC_NAME
model:SetAttribute("GeneratedNPC", true)
model:SetAttribute("CatalogAccessories", string.format("%d,%d", CATALOG_IDS.Apron, CATALOG_IDS.Beard))
model:SetAttribute("InteractionName", "Shopkeeper")
model:SetAttribute("InteractionAction", "Browse")
model:SetAttribute("InteractionKey", "F")
model:SetAttribute("InteractionDistance", 18)
model:SetAttribute("InteractionColor", Color3.fromRGB(225, 153, 32))
model:SetAttribute("InteractionHighlightColor", Color3.fromRGB(255, 208, 81))
model:SetAttribute("InteractionOffset", Vector3.new(0, 3.5, 0))
local humanoid = model:FindFirstChildOfClass("Humanoid")
assert(humanoid, "The generated Shopkeeper has no Humanoid.")
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
assert(rootPart and rootPart:IsA("BasePart"), "The generated Shopkeeper has no HumanoidRootPart.")
model.PrimaryPart = rootPart


-- Editable merchant details use the same R15 rig; no extra catalog IDs needed.
local function merchantPart(name, size, frame, color, limb)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = frame; p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = false; p.Massless = true
	p.CanCollide = false; p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = limb; weld.Part1 = p; weld.Parent = p
	return p
end
local head = model:FindFirstChild("Head")
if head then
	merchantPart("MerchantCap", Vector3.new(1.65, 0.45, 1.5), head.CFrame * CFrame.new(0, head.Size.Y / 2 + 0.14, 0), Color3.fromRGB(42, 112, 104), head)
	merchantPart("CapBrim", Vector3.new(1.85, 0.12, 1.9), head.CFrame * CFrame.new(0, head.Size.Y / 2, -0.18), Color3.fromRGB(30, 66, 65), head)
	merchantPart("GoldPin", Vector3.new(0.23, 0.23, 0.12), head.CFrame * CFrame.new(0.45, head.Size.Y / 2 + 0.18, -0.79), Color3.fromRGB(255, 208, 81), head)
end
local torso = model:FindFirstChild("LowerTorso")
if torso then
	merchantPart("CoinPouch", Vector3.new(0.65, 0.7, 0.4), torso.CFrame * CFrame.new(torso.Size.X / 2, -0.1, -0.35), Color3.fromRGB(116, 78, 46), torso)
	merchantPart("PouchClasp", Vector3.new(0.23, 0.19, 0.12), torso.CFrame * CFrame.new(torso.Size.X / 2, 0.1, -0.59), Color3.fromRGB(255, 208, 81), torso)
end

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
pcall(function() recording = History:TryBeginRecording("GenerateShopkeeperNPC", "Generate Shopkeeper NPC") end)
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
print("Shopkeeper generated in Workspace.NPCs. Move the selected model to its final location and save the place.")
