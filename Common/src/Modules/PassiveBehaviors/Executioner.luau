return {
	BeforeAttack = function(context)
		local humanoid = context.Victim:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= humanoid.MaxHealth * 0.3 then
			context.Attack *= 1.25
			context.TriggeredPassives.Executioner = true
		end
	end,
}
