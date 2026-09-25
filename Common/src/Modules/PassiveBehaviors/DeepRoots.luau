local DeepRoots = {}

function DeepRoots.OnEquip(_, state)
	state.Hits = 0
end

function DeepRoots.BeforeAttack(context, state)
	if state.Hits >= 4 then
		context.Attack *= 1.35
		context.TriggeredPassives.DeepRoots = true
	end
end

function DeepRoots.OnHitConfirmed(context, state)
	if context.TriggeredPassives.DeepRoots then
		state.Hits = 0
	else
		state.Hits = math.min(4, state.Hits + 1)
	end
end

function DeepRoots.AfterHit(context)
	if not context.TriggeredPassives.DeepRoots then
		return
	end

	local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.05)
	end
end

return DeepRoots
