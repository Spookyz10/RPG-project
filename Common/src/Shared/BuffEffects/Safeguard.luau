local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = {}
local ActiveShields: { [Model]: BasePart } = setmetatable({}, { __mode = "k" })

function Effect.Apply(character: Model)
	if ActiveShields[character] then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local resources = ReplicatedStorage:FindFirstChild("Resources")
	local buffEffects = resources and resources:FindFirstChild("BuffEffects")
	local folder = buffEffects and buffEffects:FindFirstChild("Safeguard")
	local template = folder and folder:FindFirstChild("Shield")
	if not rootPart or not rootPart:IsA("BasePart") or not template or not template:IsA("BasePart") then
		return
	end

	local shield = template:Clone()
	shield.Anchored = false
	shield.CanCollide = false
	shield.CanTouch = false
	shield.CanQuery = false
	shield.Massless = true
	shield.CFrame = rootPart.CFrame
	shield.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Name = "SafeguardWeld"
	weld.Part0 = rootPart
	weld.Part1 = shield
	weld.Parent = shield

	ActiveShields[character] = shield
end

function Effect.Stop(character: Model)
	local shield = ActiveShields[character]
	if shield then
		shield:Destroy()
		ActiveShields[character] = nil
	end
end

return Effect
