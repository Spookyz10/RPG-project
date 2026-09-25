local BriarReprisal = {}

function BriarReprisal.OnEquip(_, state)
	state.Primed = false
end

function BriarReprisal.BeforeAttack(context, state)
	if state.Primed then
		context.Attack *= 1.25
		context.TriggeredPassives.BriarReprisal = true
	end
end

function BriarReprisal.OnHitConfirmed(context, state)
	if context.TriggeredPassives.BriarReprisal then
		state.Primed = false
	end
end

function BriarReprisal.AfterDamageReceived(context, state)
	if context.Damage and context.Damage > 0 then
		state.Primed = true
	end
end

return BriarReprisal
