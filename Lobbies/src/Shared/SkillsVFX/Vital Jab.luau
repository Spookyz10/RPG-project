local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emitter = require(ReplicatedStorage.Shared.Utils.Emitter)
local WeldSystem = require(ReplicatedStorage.Shared.Utils.WeldSystem)
local VFX = {}

function VFX:Play(Character: Model)
	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	local Effect = ReplicatedStorage.Assets.VFX.Skills["Vital Jab"]:Clone() :: BasePart
	Effect.Parent = workspace
	Effect:PivotTo(RootPart.CFrame)
	WeldSystem:Weld(Effect, RootPart)
	Emitter:Emit(Effect)

	Debris:AddItem(Effect, 3)
end

return VFX
