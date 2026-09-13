return {
	AfterHit = function(context, state)
		local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		state.Hits = (state.Hits or 0) + 1
		if state.Hits % 5 ~= 0 then
			return
		end

		local healthBefore = humanoid.Health
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.04)
		if humanoid.Health > healthBefore then
			context.TriggeredPassives.Regrowth = true
		end
	end,
}
