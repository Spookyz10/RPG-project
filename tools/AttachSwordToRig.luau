-- Paste into Studio's Command Bar in Edit mode, before opening Animation Editor.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Execute em modo Edit, fora do Play.")

local Rig = workspace:FindFirstChild("Rig")
assert(Rig and Rig:IsA("Model"), "workspace.Rig precisa ser um Model R6.")
local Arm = Rig:FindFirstChild("Right Arm")
local Root = Rig:FindFirstChild("HumanoidRootPart")
assert(Arm and Arm:IsA("BasePart"), "Rig sem Right Arm.")
assert(Root and Root:IsA("BasePart"), "Rig sem HumanoidRootPart.")
assert(Rig:FindFirstChildOfClass("Humanoid"), "Rig sem Humanoid.")

local Sword = workspace:FindFirstChild("Sword") or Rig:FindFirstChild("Sword")
assert(Sword and Sword:IsA("Model"), "Sword precisa ser um Model com Handle.")
local Handle = Sword:FindFirstChild("Handle")
assert(Handle and Handle:IsA("BasePart"), "Sword sem Handle.")
local GripPoint = Handle:FindFirstChild("GripPoint")
assert(not GripPoint or GripPoint:IsA("Attachment"), "GripPoint precisa ser Attachment.")

-- Match WeaponLoader defaults; copy custom runtime values here if needed.
local Position = Sword:GetAttribute("GripPosition")
local Orientation = Sword:GetAttribute("GripOrientation")
Position = if typeof(Position) == "Vector3" then Position else Vector3.new(0, -1, 0)
Orientation = if typeof(Orientation) == "Vector3" then Orientation else Vector3.zero
local Offset = CFrame.new(Position)
	* CFrame.fromOrientation(math.rad(Orientation.X), math.rad(Orientation.Y), math.rad(Orientation.Z))
local AttachmentOffset = if GripPoint then GripPoint.CFrame else CFrame.identity

game:GetService("ChangeHistoryService"):SetWaypoint("Before attaching Sword")

-- Remove previous arm-to-sword joints, including a previous run of this script.
for _, Joint in Rig:GetDescendants() do
	if Joint:IsA("JointInstance") or Joint:IsA("WeldConstraint") then
		if (Joint.Part0 == Arm and Joint.Part1 == Handle)
			or (Joint.Part0 == Handle and Joint.Part1 == Arm) then
			Joint:Destroy()
		end
	end
end
for _, Joint in Sword:GetDescendants() do
	if Joint:GetAttribute("AnimationRigSetup") then
		Joint:Destroy()
	end
end

Sword.PrimaryPart = Handle
Sword.Parent = Rig
Sword:PivotTo(Arm.CFrame * Offset * AttachmentOffset:Inverse())

for _, Part in Rig:GetDescendants() do
	if Part:IsA("BasePart") then
		Part.Anchored = Part == Root
	end
end
for _, Part in Sword:GetDescendants() do
	if Part:IsA("BasePart") then
		Part.CanCollide = false
		Part.Massless = true
		if Part ~= Handle then
			local Weld = Instance.new("WeldConstraint")
			Weld.Name = "SwordPartWeld"
			Weld:SetAttribute("AnimationRigSetup", true)
			Weld.Part0 = Handle
			Weld.Part1 = Part
			Weld.Parent = Handle
		end
	end
end

local Grip = Instance.new("Weld")
Grip.Name = "WeaponGrip"
Grip:SetAttribute("AnimationRigSetup", true)
Grip.C0 = Offset
Grip.C1 = AttachmentOffset
Grip.Part0 = Arm
Grip.Part1 = Handle
Grip.Parent = Handle

game:GetService("Selection"):Set({ Rig })
game:GetService("ChangeHistoryService"):SetWaypoint("Sword attached to Rig")
print("Pronto! Abra o Animation Editor no Rig. Sword acompanha Right Arm; anime apenas o corpo.")
