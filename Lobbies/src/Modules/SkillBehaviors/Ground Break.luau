local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local HITBOX_SIZE = Vector3.new(12, 8, 12)
local HITBOX_OFFSET = CFrame.new(0, -2, -3)
local MARKER_NAME = "Attack"

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	local Handler = AnimationHandler.GetOrCreate(Character)
	local Track = Handler:Play("Ground Break", 0.1)
	if not Track then
		return
	end

	local Connection: RBXScriptConnection
	Connection = Track:GetMarkerReachedSignal(MARKER_NAME):Connect(function()
		if Connection then
			Connection:Disconnect()
		end

		if not Character or not Character.Parent then
			return
		end

		RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Ground Break", Character)

		Hitbox:Create({
			Size = HITBOX_SIZE,
			Part = Character.PrimaryPart,
			Drag = false,
			Offset = HITBOX_OFFSET,
			Time = 0,
			Caster = Character,
			OnHit = function(_, HitEntity)
				DamageHandler:dealDamage(Character, HitEntity, definition.Multiplier)
			end,
		})
	end)
end

return Behavior
