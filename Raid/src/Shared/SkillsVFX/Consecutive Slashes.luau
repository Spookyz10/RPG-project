local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emitter = require(ReplicatedStorage.Shared.Utils.Emitter)

local VFX = {}

function VFX:Play(HitPostiition: Vector3)
	local Effect = ReplicatedStorage.Assets.VFX.Skills["Consecutive Slashes"]:Clone() :: BasePart
	Effect.Parent = workspace
	Effect:PivotTo(CFrame.new(HitPostiition))
	Emitter:Emit(Effect)

	Debris:AddItem(Effect, 3)
end

return VFX
