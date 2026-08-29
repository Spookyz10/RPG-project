local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Effect = {}

local ORBIT_SPEED = 3
local ORBIT_OFFSET = CFrame.new(0, 0.5, 7) * CFrame.Angles(-math.pi / 2, 0, math.pi)

local ActiveShields: { [Model]: BasePart } = {}
local ActiveConnections: { [Model]: RBXScriptConnection } = {}

function Effect.Apply(Character: Model)
	if ActiveShields[Character] then
		return
	end

	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	local BuffEffect = ReplicatedStorage.Resources.BuffEffects:FindFirstChild("Safeguard")
	if not BuffEffect then
		return
	end

	local Shield = BuffEffect:Clone()
	Shield.Name = "Safeguard"
	Shield.Anchored = true
	Shield.CanCollide = false
	Shield.Parent = Character

	ActiveShields[Character] = Shield

	local Angle = 0
	ActiveConnections[Character] = RunService.Heartbeat:Connect(function(dt)
		if not Character.PrimaryPart or not Shield.Parent then
			return
		end

		Angle += ORBIT_SPEED * dt
		local Base = CFrame.new(Character.PrimaryPart.Position)
		Shield.CFrame = Base * CFrame.Angles(0, Angle, 0) * ORBIT_OFFSET
	end)
end

function Effect.Stop(Character: Model)
	local Connection = ActiveConnections[Character]
	if Connection then
		Connection:Disconnect()
		ActiveConnections[Character] = nil
	end

	local Shield = ActiveShields[Character]
	if Shield then
		Shield:Destroy()
		ActiveShields[Character] = nil
	end
end

return Effect
