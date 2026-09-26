local RS = game:GetService("ReplicatedStorage")
local Damage = require(script.Parent.Parent.DamageHandler)
local Hitbox = require(script.Parent.Parent.Hitbox)
local Remote = require(RS.Shared.Utils.RemoteManager)
return {
	Execute = function(_, caster, definition)
		local character = caster.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then return end
		Remote.SendClientEvent("SkillVFX", { All = true }, "Arc Breaker", character)
		Hitbox:Create({
			Size = Vector3.new(16, 8, 14), Part = root, Offset = CFrame.new(0, 0, -7),
			Drag = false, Time = 0, Caster = character,
			OnHit = function(_, target)
				Damage:dealDamage(character, target, definition.Multiplier)
			end,
		})
	end,
}
