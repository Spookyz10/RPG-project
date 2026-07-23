local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Server")

local IsHolding = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		IsHolding = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		IsHolding = false
	end
end)

while IsHolding do
	Remotes:FindFirstChild("Attack"):FireServer()
end
