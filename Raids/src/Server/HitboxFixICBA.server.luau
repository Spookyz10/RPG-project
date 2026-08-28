local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function isWeld(instance)
	return instance:IsA("WeldConstraint") or instance:IsA("Weld")
end

local function FixMob(mobModel)
	local RootPart = mobModel.PrimaryPart
	local Hitbox = mobModel:FindFirstChild("Hitbox")

	if not RootPart or not Hitbox then
		return
	end

	for _, descendant in mobModel:GetDescendants() do
		if isWeld(descendant) then
			if
				(descendant.Part0 == RootPart and descendant.Part1 == Hitbox)
				or (descendant.Part0 == Hitbox and descendant.Part1 == RootPart)
			then
				descendant.Part0 = RootPart
				descendant.Part1 = Hitbox
				return
			end
		end
	end

	local NewWeld = Instance.new("WeldConstraint")
	NewWeld.Name = "Weld"
	NewWeld.Part0 = RootPart
	NewWeld.Part1 = Hitbox
	NewWeld.Parent = Hitbox
end

local MobsFolder = ReplicatedStorage:WaitForChild("Mobs")

for _, child in MobsFolder:GetChildren() do
	if child:IsA("Model") then
		FixMob(child)
	end
end

MobsFolder.ChildAdded:Connect(function(child)
	if child:IsA("Model") then
		FixMob(child)
	end
end)
