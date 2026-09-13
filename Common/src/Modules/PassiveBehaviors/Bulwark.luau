return {
	BeforeIncomingDamage = function(context)
		local humanoid = context.Victim:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health >= humanoid.MaxHealth * 0.7 then
			context.Damage *= 0.85
			context.TriggeredDefenderPassives.Bulwark = true
		end
	end,
}
