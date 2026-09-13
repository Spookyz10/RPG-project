return {
	AfterHit = function(context)
		local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not context.IsCrit then return end
		local before = humanoid.Health
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + context.Damage * 0.08)
		if humanoid.Health > before then context.TriggeredPassives.Predator = true end
	end,
}
