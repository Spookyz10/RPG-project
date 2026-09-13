return {
	BeforeIncomingDamage = function(context)
		local humanoid = context.Victim:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= humanoid.MaxHealth * 0.35 then
			context.Damage *= 0.75
			context.TriggeredDefenderPassives.LastStand = true
		end
	end,
}
