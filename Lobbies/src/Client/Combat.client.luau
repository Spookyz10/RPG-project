local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

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

RunService.Heartbeat:Connect(function()
	if IsHolding then
		RemoteManager.SendServerEvent("Attack", nil)
	end
end)
