local StatusEffects = require(script.Parent.Parent.StatusEffectManager)

return {
	AfterHit = function(context)
		local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			StatusEffects:Apply(context.Victim, "Venom", { Source = context.Caster })
			context.TriggeredPassives.Venom = true
		end
	end,
}
