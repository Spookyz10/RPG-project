local RunicWard = {}

function RunicWard.OnEquip(_, state)
	state.Hits = 0
end

function RunicWard.BeforeIncomingDamage(context, state)
	if state.Hits >= 2 then
		context.Damage *= 0.6
		context.TriggeredDefenderPassives.RunicWard = true
	end
end

function RunicWard.AfterDamageReceived(context, state)
	if context.TriggeredDefenderPassives.RunicWard then
		state.Hits = 0
	elseif context.Damage and context.Damage > 0 then
		state.Hits = math.min(2, state.Hits + 1)
	end
end

return RunicWard
