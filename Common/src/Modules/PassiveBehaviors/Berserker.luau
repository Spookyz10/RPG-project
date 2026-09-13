return {
	BeforeAttack = function(context)
		local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= humanoid.MaxHealth * 0.4 then
			context.Attack *= 1.25
		end
	end,
	AfterDamageReceived = function(context)
		local humanoid = context.Victim:FindFirstChildOfClass("Humanoid")
		if not humanoid or not context.Damage or context.Damage <= 0 then
			return
		end

		local threshold = humanoid.MaxHealth * 0.4
		local previousHealth = context.PreviousHealth or humanoid.Health + context.Damage
		if humanoid.Health > 0 and humanoid.Health <= threshold and previousHealth > threshold then
			context.TriggeredDefenderPassives.Berserker = true
		end
	end,
}
