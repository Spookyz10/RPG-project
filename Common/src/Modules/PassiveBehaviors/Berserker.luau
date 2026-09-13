return {
	BeforeAttack = function(context)
		local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= humanoid.MaxHealth * 0.4 then
			context.Attack *= 1.25
			context.TriggeredPassives.Berserker = true
		end
	end,
}
