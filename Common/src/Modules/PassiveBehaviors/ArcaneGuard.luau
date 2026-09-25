local ArcaneGuard = {}

function ArcaneGuard.OnEquip(_, state)
	state.Charged = false
end

function ArcaneGuard.AfterHit(context, state)
	if context.Damage and context.Damage > 0 then
		state.Charged = true
	end
end

function ArcaneGuard.BeforeIncomingDamage(context, state)
	if state.Charged then
		context.Damage *= 0.8
		context.TriggeredDefenderPassives.ArcaneGuard = true
	end
end

function ArcaneGuard.AfterDamageReceived(context, state)
	if context.TriggeredDefenderPassives.ArcaneGuard then
		state.Charged = false
	end
end

return ArcaneGuard
