-- Require on tick to avoid the DamageHandler -> passives -> status effects cycle.
return {
	OnTick = function(target, effect)
		local humanoid = target:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			require(script.Parent.Parent.DamageHandler):heal(effect.Source, target, humanoid.MaxHealth * 0.05)
		end
	end,
}
