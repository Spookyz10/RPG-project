local PhysicsService = game:GetService("PhysicsService")

local GROUP_NAME = "Entities"

local CollisionGroups = {}

local function EnsureGroup()
	pcall(function()
		PhysicsService:RegisterCollisionGroup(GROUP_NAME)
	end)

	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(GROUP_NAME, GROUP_NAME, false)
	end)
end

EnsureGroup()

function CollisionGroups:Apply(model: Instance)
	if not model then
		return
	end

	local function SetPart(part: BasePart)
		part.CollisionGroup = GROUP_NAME
	end

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			SetPart(descendant)
		end
	end

	model.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			SetPart(descendant)
		end
	end)
end

return CollisionGroups
