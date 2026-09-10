-- Override the default Animate locomotion assets, retaining its state transitions.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local animation = ReplicatedStorage:WaitForChild("Resources"):WaitForChild("Animations")
	:WaitForChild("Other"):WaitForChild("PlayerRun")
assert(animation:IsA("Animation"), "Resources.Animations.Other.PlayerRun must be an Animation")

local connections = {}
local function disconnect()
	for _, connection in connections do connection:Disconnect() end
	table.clear(connections)
end

local function bind(character)
	disconnect()
	local animate = character:WaitForChild("Animate", 15)
	if not animate or player.Character ~= character then return end
	local function configure(object)
		if not object:IsA("Animation") then return end
		local parent = object.Parent
		if parent and parent.Parent == animate and (parent.Name == "walk" or parent.Name == "run") then
			object.AnimationId = animation.AnimationId
		end
	end
	table.insert(connections, animate.DescendantAdded:Connect(configure))
	table.insert(connections, animation:GetPropertyChangedSignal("AnimationId"):Connect(function()
		for _, object in animate:GetDescendants() do configure(object) end
	end))
	for _, object in animate:GetDescendants() do configure(object) end
end

player.CharacterAdded:Connect(bind)
player.CharacterRemoving:Connect(disconnect)
if player.Character then task.spawn(bind, player.Character) end
