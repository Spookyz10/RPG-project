return {
	BeforeAttack = function(context)
		local humanoid = context.Victim:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.MaxHealth > 0 and humanoid.Health >= humanoid.MaxHealth * 0.7 then
			context.Attack *= 1.2
			context.TriggeredPassives.VenomHunter = true
		end
	end,
}
