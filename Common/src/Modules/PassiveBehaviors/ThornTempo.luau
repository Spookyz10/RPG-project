local ThornTempo = {}

function ThornTempo.OnEquip(_, state)
	state.Hits = 0
end

function ThornTempo.BeforeAttack(context, state)
	if state.Hits >= 2 then
		context.Attack *= 1.3
		context.TriggeredPassives.ThornTempo = true
	end
end

function ThornTempo.OnHitConfirmed(context, state)
	if context.TriggeredPassives.ThornTempo then
		state.Hits = 0
	else
		state.Hits = math.min(2, state.Hits + 1)
	end
end

return ThornTempo
