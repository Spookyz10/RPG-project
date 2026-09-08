local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local WeldSystem = require(ReplicatedStorage.Shared.Utils.WeldSystem)

local Effect = {}

local ORBIT_OFFSET = CFrame.new(0, 0.5, 7) * CFrame.Angles(-math.pi / 2, 0, math.pi)
local ROTATION_SPEED = math.rad(180)

local ActiveShields: { [Model]: Instance } = {}
local ActiveOrbs: { [Model]: Instance } = {}
local ActiveConnections: { [Model]: RBXScriptConnection } = {}

function Effect.Apply(Character: Model)
	if ActiveShields[Character] then
		return
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not RootPart then
		return
	end

	local AssetsFolder = ReplicatedStorage.Resources.BuffEffects:FindFirstChild("Safeguard")
	if not AssetsFolder then
		return
	end

	local ShieldTemplate = AssetsFolder:FindFirstChild("Shield") :: BasePart?
	if not ShieldTemplate then
		return
	end

	local Shield = ShieldTemplate:Clone()
	Shield.Name = "Shield"
	Shield.Anchored = true
	Shield.CanCollide = false
	Shield.Parent = Character

	ActiveShields[Character] = Shield

	local OrbTemplate = AssetsFolder:FindFirstChild("orb") :: BasePart?
	if OrbTemplate then
		local Orb = OrbTemplate:Clone()
		Orb.Name = "SafeguardOrb"
		Orb.Anchored = false
		Orb.CanCollide = false
		Orb.CFrame = RootPart.CFrame
		Orb.Parent = workspace

		WeldSystem:Weld(RootPart, Orb)

		ActiveOrbs[Character] = Orb
	end

	local Angle = 0
	ActiveConnections[Character] = RunService.Heartbeat:Connect(function(dt)
		if not Shield.Parent or not Character:FindFirstChild("HumanoidRootPart") then
			Effect.Stop(Character)
			return
		end

		Angle += ROTATION_SPEED * dt
		local Base = CFrame.new(RootPart.Position)
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
		Debris:AddItem(Shield, 0)
		ActiveShields[Character] = nil
	end

	local Orb = ActiveOrbs[Character]
	if Orb then
		Debris:AddItem(Orb, 0)
		ActiveOrbs[Character] = nil
	end
end

return Effect
