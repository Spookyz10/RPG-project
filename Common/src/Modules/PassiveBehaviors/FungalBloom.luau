local FungalBloom = {}

function FungalBloom.OnEquip(_, state)
	state.Primed = false
end

function FungalBloom.BeforeAttack(context, state)
	if state.Primed then
		context.Attack *= 1.2
		context.TriggeredPassives.FungalBloom = true
	end
end

function FungalBloom.OnHitConfirmed(context, state)
	if context.TriggeredPassives.FungalBloom then
		state.Primed = false
	end
end

function FungalBloom.AfterHit(context, state)
	if context.IsCrit then
		state.Primed = true
	end
end

return FungalBloom
