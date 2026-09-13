local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emitter = require(ReplicatedStorage.Shared.Utils.Emitter)

local Remote = {}

function Remote:Activate(character: Model?)
	local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	local resources = ReplicatedStorage:FindFirstChild("Resources")
	local effects = resources and resources:FindFirstChild("Effects")
	local template = effects and effects:FindFirstChild("LevelUp")
	if not character or not rootPart or not rootPart:IsA("BasePart") or not template or not template:IsA("BasePart") then
		return
	end

	local effect = template:Clone()
	effect.Anchored = false
	effect.CanCollide = false
	effect.CanTouch = false
	effect.CanQuery = false
	effect.Massless = true
	effect.CFrame = rootPart.CFrame
	effect.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Name = "LevelUpWeld"
	weld.Part0 = rootPart
	weld.Part1 = effect
	weld.Parent = effect

	Emitter:Emit(effect)
	Debris:AddItem(effect, 3)
end

return Remote
