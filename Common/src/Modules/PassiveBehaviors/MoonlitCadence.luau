local MoonlitCadence = {}

function MoonlitCadence.OnEquip(_, state)
	state.Hits = 0
end

function MoonlitCadence.BeforeAttack(context, state)
	if state.Hits >= 3 then
		context.ForceCritical = true
		context.CriticalMultiplier += 0.5
		context.TriggeredPassives.MoonlitCadence = true
	end
end

function MoonlitCadence.OnHitConfirmed(context, state)
	if context.TriggeredPassives.MoonlitCadence then
		state.Hits = 0
	else
		state.Hits = math.min(3, state.Hits + 1)
	end
end

return MoonlitCadence
