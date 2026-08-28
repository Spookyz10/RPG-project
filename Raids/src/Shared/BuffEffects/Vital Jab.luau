local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = {}

function Effect.Apply(Character: Model)
	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	local BuffEffect = ReplicatedStorage.Resources.BuffEffects:FindFirstChild("Vital Jab")
	if not BuffEffect then
		return
	end

	for _, particle in BuffEffect:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle:Clone().Parent = RootPart
			particle.Name = "Vital Jab"
		end
	end
end

function Effect.Stop(Character: Model)
	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	for _, particle in RootPart:GetDescendants() do
		if particle:IsA("ParticleEmitter") and particle.Name == "Vital Jab" then
			particle:Destroy()
		end
	end
end

return Effect
