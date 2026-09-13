local StatusEffects = require(script.Parent.Parent.StatusEffectManager)

return {
	BeforeAttack = function(context)
		local venom = StatusEffects:Get(context.Victim, "Venom")
		if venom and venom.Source == context.Caster then
			context.Attack *= 1.15
			context.TriggeredPassives.Venom = true
		end
	end,

	AfterHit = function(context)
		local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			StatusEffects:Apply(context.Victim, "Venom", { Source = context.Caster })
		end
	end,
}
