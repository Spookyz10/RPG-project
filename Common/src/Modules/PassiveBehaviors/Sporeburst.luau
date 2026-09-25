local Sporeburst = {}

function Sporeburst.OnEquip(_, state)
	state.Hits = 0
end

function Sporeburst.BeforeAttack(context, state)
	if state.Hits >= 2 then
		context.ForceCritical = true
		context.CriticalMultiplier += 0.5
		context.TriggeredPassives.Sporeburst = true
	end
end

function Sporeburst.OnHitConfirmed(context, state)
	if context.TriggeredPassives.Sporeburst then
		state.Hits = 0
	else
		state.Hits = math.min(2, state.Hits + 1)
	end
end

return Sporeburst
