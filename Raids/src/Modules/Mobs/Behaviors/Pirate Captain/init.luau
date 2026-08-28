local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Difficulty = ReplicatedStorage:FindFirstChild("Difficulty")
	and ReplicatedStorage:FindFirstChild("Difficulty").Value

local Behavior = nil

if Difficulty and script:FindFirstChild(Difficulty) then
	Behavior = script:FindFirstChild(Difficulty)
else
	Behavior = script:FindFirstChild("Normal")
end

return Behavior
